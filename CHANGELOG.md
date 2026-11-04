# Changelog

## [1.0.0-alpha.16](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.15...v1.0.0-alpha.16) (2026-11-04)


### ⚠ Breaking changes

* the minimum supported Elixir version is now 1.16.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>

### 🐛 Bug Fixes

* remove unused Logger require ([9522e66](https://github.com/sheerlox/nodelix/commit/9522e66a8441e3d410f164d0b38b792625082091))
* update latest Node LTS version to 26.13.0 ([99d5ad4](https://github.com/sheerlox/nodelix/commit/99d5ad4c069cf934cabb508375c398d18793527b))


### 🚨 Tests

* run Nodelix tests synchronously ([993289a](https://github.com/sheerlox/nodelix/commit/993289a6698c2829bfa6c5cf468dda873c654710))


### ⚙️ Continuous Integrations

* pin runner image and drop Elixir < 1.16 ([7e0d3cf](https://github.com/sheerlox/nodelix/commit/7e0d3cfdbc4766fb1a3c81266cb9cb945e71310d))
* **renovate:** extend required base config ([9b0ea86](https://github.com/sheerlox/nodelix/commit/9b0ea86562a2677aa3973eddd5804efb9b998159))
* test against Elixir 1.17-1.20 and pin release runner to ubuntu-24.04 ([79f7db5](https://github.com/sheerlox/nodelix/commit/79f7db53474b6530ca79412bffa43451b08ed1d0))
* update Erlang/Elixir used by release to OTP 29.1.2 / 1.20.5 ([6ba218d](https://github.com/sheerlox/nodelix/commit/6ba218d548bc308c2822c48df04576eed74e6a1e))


### ♻️ Chores

* **action:** update actions/cache action to v4.2.1 ([2fef404](https://github.com/sheerlox/nodelix/commit/2fef40434053b100a7aeffd4e27c38f3771de38f))
* **action:** update actions/cache action to v4.2.2 ([#39](https://github.com/sheerlox/nodelix/issues/39)) ([8ce0b53](https://github.com/sheerlox/nodelix/commit/8ce0b53dd10887821647b15638c0d70ac3444d91))
* **action:** update actions/cache action to v4.2.3 ([5cbde34](https://github.com/sheerlox/nodelix/commit/5cbde340391b028cded2bcbe4867973eb3408bae))
* **action:** update actions/setup-node action to v4.2.0 ([8bfba96](https://github.com/sheerlox/nodelix/commit/8bfba960a16038df647d717bcd5fdccbbb953040))
* **action:** update actions/setup-node action to v4.3.0 ([#42](https://github.com/sheerlox/nodelix/issues/42)) ([23a2577](https://github.com/sheerlox/nodelix/commit/23a25772d5958ed37ef74c547a72f5a848403f45))
* **deps:** lock file maintenance ([7e5d133](https://github.com/sheerlox/nodelix/commit/7e5d1335ca647a8eb3c9e2d51e97ab740e638120))
* **deps:** update dependency dialyxir to v1.4.5 ([#29](https://github.com/sheerlox/nodelix/issues/29)) ([5f6b695](https://github.com/sheerlox/nodelix/commit/5f6b6957ef48edb9b0afc295e58cb3cb338181b1))
* **deps:** update dependency elixir to v1.18.1 ([#26](https://github.com/sheerlox/nodelix/issues/26)) ([de80ed7](https://github.com/sheerlox/nodelix/commit/de80ed781ae837ea684c2eb726d7738e4043804a))
* **deps:** update dependency erlang to v27 ([#27](https://github.com/sheerlox/nodelix/issues/27)) [skip ci] ([b371716](https://github.com/sheerlox/nodelix/commit/b371716b4288e4181ebe21fbfafdb6138e22b6b4))
* **deps:** update dependency ex_doc to v0.37.0 ([#30](https://github.com/sheerlox/nodelix/issues/30)) ([5c5894c](https://github.com/sheerlox/nodelix/commit/5c5894cce4221331004167f07f6706450bcfa496))
* **deps:** update dependency ex_doc to v0.37.1 ([9574b5f](https://github.com/sheerlox/nodelix/commit/9574b5f982a3ca05c827451e655fd3c86dbbc90d))
* **deps:** update dependency ex_doc to v0.37.2 ([94b49d5](https://github.com/sheerlox/nodelix/commit/94b49d56f74681a4b41425a07f821075fceff2cf))
* **deps:** update dependency ex_doc to v0.37.3 ([#40](https://github.com/sheerlox/nodelix/issues/40)) ([8d9c4a5](https://github.com/sheerlox/nodelix/commit/8d9c4a5c8df659bcc12ee3eac0ae426a23e0bc9a))

## [1.0.0-alpha.15](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.14...v1.0.0-alpha.15) (2025-01-10)


### ✨ Features

* add exponential backoff to archive download ([#23](https://github.com/sheerlox/nodelix/issues/23)) ([07e592b](https://github.com/sheerlox/nodelix/commit/07e592b77c259f396495d85f386efc847756af4f))


### ⚙️ Continuous Integrations

* **renovate:** keep dev runtime version up-to-date ([a246761](https://github.com/sheerlox/nodelix/commit/a246761ba2df8495e23061f24568dc96ff378f95))


### ♻️ Chores

* **action:** update actions/cache action to v4 ([#16](https://github.com/sheerlox/nodelix/issues/16)) [skip ci] ([f827bef](https://github.com/sheerlox/nodelix/commit/f827befac5e8bbae86f04b45da5858936c15eef0))
* **deps:** lock file maintenance ([7002da2](https://github.com/sheerlox/nodelix/commit/7002da2f7c9c33546000e15ffc5fa1deba3814ad))
* **deps:** lock file maintenance ([#22](https://github.com/sheerlox/nodelix/issues/22)) [skip ci] ([786fed8](https://github.com/sheerlox/nodelix/commit/786fed80b32f1479adb56126f12e94f24d2fee07))
* **deps:** update node.js to v22.13.0 ([#19](https://github.com/sheerlox/nodelix/issues/19)) [skip ci] ([3af86b6](https://github.com/sheerlox/nodelix/commit/3af86b638bca6228061698637cbd5cb14c94eb27))

## [1.0.0-alpha.14](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.13...v1.0.0-alpha.14) (2025-01-09)


### 🐛 Bug Fixes

* work on concurrent GPG imports leading to flaky key verification ([104b966](https://github.com/sheerlox/nodelix/commit/104b966d3e1cacda3533d8fdc21c757d973aed85)), closes [#17](https://github.com/sheerlox/nodelix/issues/17)


### ⚙️ Continuous Integrations

* **action:** update actions/cache action to v3.4.0 ([#9](https://github.com/sheerlox/nodelix/issues/9)) ([0dc4aaa](https://github.com/sheerlox/nodelix/commit/0dc4aaa8268d0a6dd8b5cfb7be54d80fbc7afffb))
* **action:** update actions/checkout action to v4.2.2 ([#10](https://github.com/sheerlox/nodelix/issues/10)) ([8973818](https://github.com/sheerlox/nodelix/commit/8973818654efa4fb533c6d99be86be475fedb04d))
* **action:** update actions/setup-node action to v4.1.0 ([#11](https://github.com/sheerlox/nodelix/issues/11)) ([229cf16](https://github.com/sheerlox/nodelix/commit/229cf1690d2802e6b02952b6668cd77e0bb1c46d))
* **action:** update erlef/setup-beam action to v1.18.2 ([#13](https://github.com/sheerlox/nodelix/issues/13)) ([a25f7b4](https://github.com/sheerlox/nodelix/commit/a25f7b4daa8518f513df5ef6db76d1cc5eba316c))
* **action:** update insurgent-lab/is-in-pr-action action to v0.2.0 ([#14](https://github.com/sheerlox/nodelix/issues/14)) ([979741a](https://github.com/sheerlox/nodelix/commit/979741a53d25f60326b7c2eb69f3c2bad05b1560))


### ♻️ Chores

* **deps:** lock file maintenance ([#18](https://github.com/sheerlox/nodelix/issues/18)) ([98bb738](https://github.com/sheerlox/nodelix/commit/98bb738781757dead0014f5d5cc50682a05fed47))

## [1.0.0-alpha.13](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.12...v1.0.0-alpha.13) (2024-12-21)


### ✨ Features

* add `run_lts/2` and `install_and_run_lts/2` ([717d375](https://github.com/sheerlox/nodelix/commit/717d3755b42ef5184b330ad8cc0d3e49d196c189))


### 🐛 Bug Fixes

* update latest Node LTS version to 22.12.0 ([337e427](https://github.com/sheerlox/nodelix/commit/337e427fb24fb7cd460b2d97e06cfc9090af5881))


### ♻️ Chores

* **deps:** lock file maintenance ([be6d387](https://github.com/sheerlox/nodelix/commit/be6d387d3f1d7f6cf8c4ec1081562cabfcc47e57))
* update Node to 22.10.0 in .tool-versions ([0b270dd](https://github.com/sheerlox/nodelix/commit/0b270dd57a53d886a9169ea1b10fe99d5e01b088))

## [1.0.0-alpha.12](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.11...v1.0.0-alpha.12) (2024-06-20)


### 🐛 Bug Fixes

* receive signing keys from nodejs/release-keys repo ([cb9de75](https://github.com/sheerlox/nodelix/commit/cb9de75ff0085a464d8745660a6cac6affcf54a1))
* update latest Node LTS version to 20.14.0 ([6ed4f24](https://github.com/sheerlox/nodelix/commit/6ed4f24342258af91d282449236589f87376441e))


### ♻️ Chores

* fix renovate config ([514b9cb](https://github.com/sheerlox/nodelix/commit/514b9cb7e6dc93263cd48855863a67b9c41e8e72))

## [1.0.0-alpha.11](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.10...v1.0.0-alpha.11) (2024-06-11)


### 🐛 Bug Fixes

* ignore revoked PGP key import errors ([35e6674](https://github.com/sheerlox/nodelix/commit/35e66749d772a3a23503b5def1baeaf2d3b16ca1))


### ♻️ Chores

* configure renovate ([7db3c3c](https://github.com/sheerlox/nodelix/commit/7db3c3c2f22aa266d59de75c0984faff5c4514c8))
* **release:** v1.0.0-alpha.11 [skip ci] ([0b2bf62](https://github.com/sheerlox/nodelix/commit/0b2bf62045c4d7e1da7824f8ea0c3f67a59cab47))

## [1.0.0-alpha.11](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.10...v1.0.0-alpha.11) (2024-06-11)


### 🐛 Bug Fixes

* ignore revoked PGP key import errors ([35e6674](https://github.com/sheerlox/nodelix/commit/35e66749d772a3a23503b5def1baeaf2d3b16ca1))

## [1.0.0-alpha.10](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.9...v1.0.0-alpha.10) (2024-05-02)


### 🐛 Bug Fixes

* update latest Node LTS version to 20.12.2 ([#2](https://github.com/sheerlox/nodelix/issues/2)) ([9eb27a0](https://github.com/sheerlox/nodelix/commit/9eb27a04f81483659af692c4f811b400698031e1))


### ♻️ Chores

* **readme:** add Hex.pm badges ([1a74df1](https://github.com/sheerlox/nodelix/commit/1a74df1018f6e68bebb729003fe0f76128e6f5eb))

## [1.0.0-alpha.9](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.8...v1.0.0-alpha.9) (2023-12-01)


### ⚠ Breaking changes

* `version` is now an argument / mix flag instead of a global configuration

### ✨ Features

* remove version from application configuration ([06c539f](https://github.com/sheerlox/nodelix/commit/06c539f7cdcafe1efedaf626a76c9ccd3dd1b603))

## [1.0.0-alpha.8](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.7...v1.0.0-alpha.8) (2023-11-30)


### ⚠ Breaking changes

* `--if-missing` is now the default, use `--force` to reinstall an existing version

### ✨ Features

* don't reinstall by default & add force install flag ([0bb58d0](https://github.com/sheerlox/nodelix/commit/0bb58d06b77db15a2b3da66bf6cd4de18f5cded2))

## [1.0.0-alpha.7](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.6...v1.0.0-alpha.7) (2023-11-29)


### ⚠ Breaking changes

* the profile is no longer the first argument of `mix nodelix`

### ✨ Features

* add `mix nodelix.npm` task ([8f3b22c](https://github.com/sheerlox/nodelix/commit/8f3b22c46ea5c79b3a1e9d817d66f81ebeca2f31))
* make profile a task option ([47d05ed](https://github.com/sheerlox/nodelix/commit/47d05ed813bf5893ffabf56c93a7e80bfa8a9383))

## [1.0.0-alpha.6](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.5...v1.0.0-alpha.6) (2023-11-29)


### 🛠 Builds

* **deps:** update dependency gpg_ex to v1.0.0-alpha.4 ([3e1353f](https://github.com/sheerlox/nodelix/commit/3e1353f6ff443ec427651d49402a8e98073b1e37))

## [1.0.0-alpha.5](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.4...v1.0.0-alpha.5) (2023-11-28)


### 🛠 Builds

* update dependency semantic-release-hex to v1.1.1 ([df783d9](https://github.com/sheerlox/nodelix/commit/df783d9fb2b2fdb5cbb42ce35597c85ecfd6c795))


### ⚙️ Continuous Integrations

* update semantic-release config ([06e13e0](https://github.com/sheerlox/nodelix/commit/06e13e078d30b0ff639c0be7b403d36fae5f4981))

Changelog

## [1.0.0-alpha.4](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.3...v1.0.0-alpha.4) (2023-11-28)


### ✨ Features

* add Node.js `VersionManager` module & Mix tasks ([#1](https://github.com/sheerlox/nodelix/issues/1)) ([cc5d14d](https://github.com/sheerlox/nodelix/commit/cc5d14d678a8db3fa130398efc340648d741d376))

# Changelog

## [1.0.0-alpha.3](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.2...v1.0.0-alpha.3) (2023-11-24)


### 📚 Documentation

* **readme:** add do not use warning ([1db5348](https://github.com/sheerlox/nodelix/commit/1db53484ccab2d5192b382a6be8d61b629405aa4))


### ⚙️ Continuous Integrations

* handle hex publishing in semantic-release ([aeeba12](https://github.com/sheerlox/nodelix/commit/aeeba12e4bb16ff8b555188572214ed3f6e03575))
* unpublish next version if release fails ([9ca1f44](https://github.com/sheerlox/nodelix/commit/9ca1f44a10afc2ea16cfbe80af80ca08afeffe39))

## [1.0.0-alpha.2](https://github.com/sheerlox/nodelix/compare/v1.0.0-alpha.1...v1.0.0-alpha.2) (2023-11-22)


### 🛠 Builds

* **hex:** add main field to docs configuration ([85324c1](https://github.com/sheerlox/nodelix/commit/85324c1d1b99c2a2a22a68d24221863b5b1515ad))


### ⚙️ Continuous Integrations

* add test & release workflows ([afa22e1](https://github.com/sheerlox/nodelix/commit/afa22e1695fabdcbd3e270604ddba09bd28aab28))


### ♻️ Chores

* **deps:** update dependency semantic-release-hex to v1.1.0 ([21ac76c](https://github.com/sheerlox/nodelix/commit/21ac76c299d185fa7ba45bdac5e51e49804be5f0))

## 1.0.0-alpha.1 (2023-11-22)


### 🛠 Builds

* **hex:** add package metadata ([3f773a3](https://github.com/sheerlox/nodelix/commit/3f773a37493fe80ea4b35770588ce3246a42f5af))


### 📚 Documentation

* setup ex_doc ([1de8541](https://github.com/sheerlox/nodelix/commit/1de8541a7a9a743fcaa6dd9277c89e1aa8981b13))


### ⚙️ Continuous Integrations

* setup semantic-release ([29815b7](https://github.com/sheerlox/nodelix/commit/29815b7421f1357338f8a405ed28ad5ebea02359))


### ♻️ Chores

* add license file ([8bf963d](https://github.com/sheerlox/nodelix/commit/8bf963dd4d7f514aaa23ff96110cd42f5c12c82b))
* initialize project ([f8fc53a](https://github.com/sheerlox/nodelix/commit/f8fc53abd2c81f9ee2854faf0b86d824b56bbe69))
