// The parts of github-script's injected client and core this module uses.
/**
 * @typedef {object} Octokit
 * @property {(route: string, params?: Record<string, unknown>) => Promise<{ data: any }>} request
 * @property {(route: string, params?: Record<string, unknown>) => Promise<any[]>} paginate
 * @property {(query: string, variables?: Record<string, unknown>) => Promise<any>} graphql
 */
/**
 * @typedef {object} Core
 * @property {(message: string) => void} info
 * @property {(message: string) => void} warning
 * @property {{ addRaw: (text: string) => { write: () => Promise<unknown> } }} summary
 */

/**
 * @typedef {object} Issue A per-repo ci-health issue, as the search returns it.
 * @property {string} html_url
 * @property {string} repository_url
 * @property {string} updated_at
 * @property {string | null} body
 * @property {{ name: string }[]} labels
 */

/**
 * @typedef {object} Row
 * @property {string} repo owner/name
 * @property {string} url
 * @property {"green" | "red" | "unknown"} state
 * @property {string | null} redSince
 * @property {number | null} p50
 * @property {string} updated
 */

export const TITLE = "Nix CI health";
export const QUERY = "label:ci-health is:issue is:open is:public user:UnstoppableMango org:unmango";
const RED = "ci-health:red";
const MARKER = /^<!-- ci-health (\{.*?\}) -->/;
const SLOW_SECONDS = 300;
const STALE_HOURS = 48;
const HOUR = 3_600_000;

/**
 * @param {string | null} body
 * @returns {{ state?: string, red_since?: unknown, p50?: unknown }}
 */
function marker(body) {
  const match = body?.match(MARKER);
  if (!match) return {};
  try {
    return JSON.parse(match[1]) ?? {};
  } catch {
    return {};
  }
}

/**
 * @param {Issue} issue
 * @returns {Row}
 */
export function toRow(issue) {
  const m = marker(issue.body);
  const red = issue.labels.some((l) => l.name === RED);
  return {
    repo: issue.repository_url.split("/").slice(-2).join("/"),
    url: issue.html_url,
    // The label holds through an unknown run, as the per-repo issue does.
    state: red ? "red" : m.state === "green" ? "green" : "unknown",
    redSince: red && typeof m.red_since === "string" ? m.red_since : null,
    p50: typeof m.p50 === "number" ? m.p50 : null,
    updated: issue.updated_at,
  };
}

/** @type {(seconds: number | null) => string} */
const duration = (s) => (s === null ? "–" : `${Math.floor(s / 60)}m ${String(s % 60).padStart(2, "0")}s`);

/** @type {(iso: string) => string} */
const minute = (iso) => iso.replace(/:\d\d(\.\d+)?Z$/, "Z");

const ORDER = { red: 0, unknown: 1, green: 2 };

/**
 * @param {Row[]} rows
 * @param {{ runUrl: string, now: Date }} opts
 */
export function render(rows, { runUrl, now }) {
  const sorted = [...rows].sort((a, b) => ORDER[a.state] - ORDER[b.state] || a.repo.localeCompare(b.repo));
  const icon = { red: "🔴 red", unknown: "⚪ unknown", green: "🟢 green" };
  return [
    "| Repo | `main` | Red since | `required` p50 |",
    "| --- | --- | --- | --- |",
    ...sorted.map((r) => `| [${r.repo}](${r.url}) | ${icon[r.state]} | ${r.redSince ? minute(r.redSince) : "–"} | ${duration(r.p50)} |`),
    "",
    `Public repos whose \`ci-health\` job has run. [Updated](${runUrl}) ${minute(now.toISOString())}.`,
    "",
  ].join("\n");
}

/**
 * The red streaks to page for this hour: past 24 hours, and within an hour
 * of a whole number of days, so an hourly run pages once a day with no state.
 *
 * @param {Row[]} rows
 * @param {Date} now
 * @returns {Row[]}
 */
export function pages(rows, now) {
  return rows.filter((r) => {
    if (r.state !== "red" || !r.redSince) return false;
    const hours = (now.getTime() - Date.parse(r.redSince)) / HOUR;
    return hours >= 24 && hours % 24 < 1;
  });
}

/**
 * What the issues show that isn't a page: slow gates, unknown states, and
 * issues the per-repo job stopped updating.
 *
 * @param {Row[]} rows
 * @param {Date} now
 * @returns {string | null}
 */
export function digest(rows, now) {
  /** @type {string[]} */
  const lines = [];
  for (const r of [...rows].sort((a, b) => a.repo.localeCompare(b.repo))) {
    const notes = [];
    if (r.p50 !== null && r.p50 > SLOW_SECONDS) notes.push(`\`required\` p50 ${duration(r.p50)}`);
    if (r.state === "unknown") notes.push("no `required` result");
    if (now.getTime() - Date.parse(r.updated) > STALE_HOURS * HOUR) notes.push(`not updated since ${minute(r.updated)}`);
    if (notes.length > 0) lines.push(`- [${r.repo}](${r.url}): ${notes.join("; ")}`);
  }
  if (lines.length === 0) return null;
  return ["Weekly digest", "", ...lines, ""].join("\n");
}

/**
 * @param {object} opts
 * @param {Octokit} opts.github
 * @param {Core} opts.core
 * @param {Record<string, string>} opts.inputs
 * @param {(url: string, init: RequestInit) => Promise<Response>} [opts.post]
 * @param {() => Date} [opts.now]
 */
export async function run({ github, core, inputs, post = fetch, now = () => new Date() }) {
  const [owner, name] = inputs.repository.split("/");
  const repo = { owner, repo: name };
  const at = now();

  /** @type {Issue[]} */
  const found = await github.paginate("GET /search/issues", { q: QUERY, per_page: 100 });
  const rows = found.map(toRow);
  const body = render(rows, { runUrl: inputs["run-url"], now: at });
  await core.summary.addRaw(body).write();

  /** @type {{ number: number, node_id: string, title: string, pull_request?: unknown }[]} */
  const open = await github.paginate("GET /repos/{owner}/{repo}/issues", { ...repo, state: "open", per_page: 100 });
  let issue = open.find((i) => !i.pull_request && i.title === TITLE);
  if (issue) {
    await github.request("PATCH /repos/{owner}/{repo}/issues/{issue_number}", { ...repo, issue_number: issue.number, body });
  } else {
    ({ data: issue } = await github.request("POST /repos/{owner}/{repo}/issues", { ...repo, title: TITLE, body }));
    try {
      await github.graphql("mutation($id: ID!) { pinIssue(input: { issueId: $id }) { issue { id } } }", { id: issue?.node_id });
    } catch (/** @type {any} */ e) {
      core.warning(`could not pin #${issue?.number}: ${e.message}`);
    }
  }

  if (inputs.digest === "true") {
    const text = digest(rows, at);
    if (text) await github.request("POST /repos/{owner}/{repo}/issues/{issue_number}/comments", { ...repo, issue_number: issue?.number, body: text });
  }

  if (inputs.page !== "true") return;
  for (const r of pages(rows, at)) {
    const days = Math.floor((at.getTime() - Date.parse(/** @type {string} */ (r.redSince))) / (24 * HOUR));
    if (!inputs["ntfy-topic"]) {
      core.warning(`${r.repo} has been red for ${days}d, but there is no ntfy topic to page`);
      continue;
    }
    const res = await post(`${inputs["ntfy-url"]}/${inputs["ntfy-topic"]}`, {
      method: "POST",
      headers: { Title: `${r.repo}: main red for ${days}d`, Tags: "rotating_light", Click: r.url },
      body: `main in ${r.repo} has been red since ${minute(/** @type {string} */ (r.redSince))}.`,
    });
    if (!res.ok) core.warning(`paging for ${r.repo} failed: ${res.status}`);
    else core.info(`paged for ${r.repo}`);
  }
}
