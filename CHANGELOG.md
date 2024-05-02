# Changelog

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
