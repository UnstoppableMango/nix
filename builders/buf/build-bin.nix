{
  build,
  name,
  outputType ? "binpb",
  ...
}@attrs:
build (
  {
    output = "$out/bin/${name}.${outputType}";
    env.preRun = "mkdir -p $out/bin";
  }
  // attrs
)
