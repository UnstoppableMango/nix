import { test } from "node:test";
import assert from "node:assert/strict";
import { toRow, render, pages, digest, run, QUERY, TITLE } from "./aggregate.mjs";

const issue = (repo, { body = null, red = false, updated = "2026-11-24T00:00:00Z" } = {}) => ({
  html_url: `https://github.com/${repo}/issues/1`,
  repository_url: `https://api.github.com/repos/${repo}`,
  updated_at: updated,
  body,
  labels: red ? [{ name: "ci-health" }, { name: "ci-health:red" }] : [{ name: "ci-health" }],
});
const marker = (m) => `<!-- ci-health ${JSON.stringify(m)} -->\n\n| | |`;

test("toRow reads the label and the marker", () => {
  assert.deepEqual(toRow(issue("o/a", { body: marker({ state: "green", red_since: null, p50: 61, p90: 90 }) })), {
    repo: "o/a",
    url: "https://github.com/o/a/issues/1",
    state: "green",
    redSince: null,
    p50: 61,
    updated: "2026-11-24T00:00:00Z",
  });
  const red = toRow(issue("o/b", { red: true, body: marker({ state: "unknown", red_since: "2026-11-20T09:00:00Z", p50: null }) }));
  assert.equal(red.state, "red");
  assert.equal(red.redSince, "2026-11-20T09:00:00Z");
  assert.equal(toRow(issue("o/c", { body: "<!-- ci-health {broken -->" })).state, "unknown");
  assert.equal(toRow(issue("o/d")).p50, null);
});

const row = (repo, over = {}) => ({ repo, url: `https://x/${repo}`, state: "green", redSince: null, p50: 100, updated: "2026-11-24T00:00:00Z", ...over });

test("render lists red repos first", () => {
  const body = render([row("o/b"), row("o/a", { state: "red", redSince: "2026-11-20T09:00:12Z", p50: 3725 })], {
    runUrl: "https://run",
    now: new Date("2026-11-24T10:07:30Z"),
  });
  assert.equal(
    body,
    [
      "| Repo | `main` | Red since | `required` p50 |",
      "| --- | --- | --- | --- |",
      "| [o/a](https://x/o/a) | 🔴 red | 2026-11-20T09:00Z | 62m 05s |",
      "| [o/b](https://x/o/b) | 🟢 green | – | 1m 40s |",
      "",
      "Public repos whose `ci-health` job has run. [Updated](https://run) 2026-11-24T10:07Z.",
      "",
    ].join("\n"),
  );
});

test("pages fires once a day from the first full day red", () => {
  const red = row("o/a", { state: "red", redSince: "2026-11-20T09:00:00Z" });
  const at = (iso) => pages([red], new Date(iso)).length;
  assert.equal(at("2026-11-21T08:59:00Z"), 0);
  assert.equal(at("2026-11-21T09:00:00Z"), 1);
  assert.equal(at("2026-11-21T09:59:00Z"), 1);
  assert.equal(at("2026-11-21T10:00:00Z"), 0);
  assert.equal(at("2026-11-22T09:30:00Z"), 1);
  assert.equal(pages([row("o/b"), row("o/c", { state: "red" })], new Date("2026-11-22T09:30:00Z")).length, 0);
});

test("digest lists slow, unknown and stale repos", () => {
  const now = new Date("2026-11-24T00:00:00Z");
  assert.equal(digest([row("o/a")], now), null);
  assert.equal(
    digest([row("o/c", { updated: "2026-11-21T00:00:00Z" }), row("o/b", { state: "unknown", p50: 400 })], now),
    [
      "Weekly digest",
      "",
      "- [o/b](https://x/o/b): `required` p50 6m 40s; no `required` result",
      "- [o/c](https://x/o/c): not updated since 2026-11-21T00:00Z",
      "",
    ].join("\n"),
  );
});

function fakeApi({ found, open }) {
  const calls = [];
  return {
    calls,
    async paginate(route, params) {
      if (route === "GET /search/issues") {
        assert.equal(params.q, QUERY);
        return found;
      }
      assert.equal(route, "GET /repos/{owner}/{repo}/issues");
      return open;
    },
    async request(route, params) {
      calls.push([route, params]);
      return { data: { number: 3, node_id: "I3" } };
    },
    async graphql(query, variables) {
      calls.push(["graphql", variables]);
      return {};
    },
  };
}

const core = { info() {}, warning() {}, summary: { addRaw: () => ({ write: async () => {} }) } };
const inputs = { repository: "U/nix", "run-url": "https://run", digest: "false", page: "true", "ntfy-url": "https://ntfy", "ntfy-topic": "t" };
const red = issue("o/a", { red: true, body: marker({ state: "red", red_since: "2026-11-20T09:00:00Z", p50: 400 }) });

test("run rewrites the issue and pages a streak in its hour", async () => {
  const github = fakeApi({ found: [red], open: [{ number: 2, title: TITLE }] });
  const posted = [];
  const post = async (url, init) => {
    posted.push([url, init.headers.Title]);
    return { ok: true, status: 200 };
  };
  await run({ github, core, inputs, post, now: () => new Date("2026-11-22T09:07:00Z") });
  assert.deepEqual(
    github.calls.map(([r]) => r),
    ["PATCH /repos/{owner}/{repo}/issues/{issue_number}"],
  );
  assert.deepEqual(posted, [["https://ntfy/t", "o/a: main red for 2d"]]);
});

test("run opens and pins the issue, and comments the digest without paging", async () => {
  const github = fakeApi({ found: [red], open: [] });
  const post = async () => assert.fail("paged");
  await run({ github, core, inputs: { ...inputs, digest: "true", page: "false" }, post, now: () => new Date("2026-11-22T09:07:00Z") });
  assert.deepEqual(
    github.calls.map(([r]) => r),
    ["POST /repos/{owner}/{repo}/issues", "graphql", "POST /repos/{owner}/{repo}/issues/{issue_number}/comments"],
  );
  assert.equal(github.calls[2][1].issue_number, 3);
});

test("run keeps paging after a delivery error", async () => {
  const other = issue("o/b", { red: true, body: marker({ state: "red", red_since: "2026-11-20T09:00:00Z", p50: 400 }) });
  const github = fakeApi({ found: [red, other], open: [{ number: 2, title: TITLE }] });
  const warnings = [];
  const posted = [];
  const post = async (url, init) => {
    posted.push(init.headers.Title);
    if (posted.length === 1) throw new Error("offline");
    return { ok: true, status: 200 };
  };
  await run({ github, core: { ...core, warning: (m) => warnings.push(m) }, inputs, post, now: () => new Date("2026-11-22T09:07:00Z") });
  assert.equal(posted.length, 2);
  assert.deepEqual(warnings, ["paging for o/a failed: offline"]);
});
