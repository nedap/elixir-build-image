# Image builder for elixir projects

Builds an image for each of the debian versions specified as `buildpack_tag` [in the workflow file](https://github.com/nedap/elixir-build-image/blob/master/.github/workflows/docker-publish.yml#L13)

## Releasing

To create a new release:
  * commit your code to master
  * create a GH release
    * go to [releases](https://github.com/nedap/elixir-build-image/releases) -> "Draft a new release"
    * select tag: <your tag here>, target: master, Release title: <your tag here>, check "Set as the latest release" and publish
