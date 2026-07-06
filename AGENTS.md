# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

## Project Structure

- MoonBit packages are organized per directory; each directory contains a
  `moon.pkg` file listing its dependencies.
- In the toplevel directory, there is a `moon.mod` file listing module
  metadata.

## Coding convention

- MoonBit code is organized in block style, each block is separated by `///|`.
- Keep files focused by responsibility and prefer small packages with clear
  boundaries.

## Tooling

- Run `moon check` frequently during implementation.
- Run `moon test` for behavioral verification.
- Run `moon info && moon fmt` before handoff to refresh interfaces and format.
