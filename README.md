## LMake

LMake is a high-performance CLI tool designed to instantly create project licenses.

---

### Executable

Compiles to a single, static binary. No external assets or networking required.

### Usage

You can use the CLI to output specific licenses to a file:

```bash
LMake mit # defaults to LICENSE.txt
```

You can also specify file:

```bash
LMake mit LICENSE.md # writes into LICENSE.md
```

It will list all available licenses for unknown identifier:

```bash
LMake help # "help" is unknown so it will list available identifiers :)
```

### License

This project is licensed under the MIT License.
