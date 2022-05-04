# Etch ⚔️

**Etch** is a command-line tool for scaffolding out new programming projects using repository layouts I personally use often.

I have a [big archive of past projects](https://thesephist.com/projects/), and when I start new projects, I usually begin by copying over the parts that don't really change all that much between projects — config files, stylesheets and color themes, libraries, folder structure, the basics of a single-page app or backend server. With `etch`, rather than copying those files manually by hand every time, I can type

```sh
etch new web --name "YC Vibe Check" --slug ycvibecheck --port 8080
```

and immediately begin working with a fully set-up app. You can think of it like a kind of a `create-react-app` for my personal repository layouts.

Etch is also designed to be able to grow and be customized over time as my development styles change. Each template is described as a collection of files in the `./tpl` directory and the `config.oak` configuration script, as something like this:

```js
web: {
    description: 'Full-stack Oak web application'
    params: [
        ['name', string, 'Name of the project']
        ['slug', string, 'Slug for the project, lowercase & no spaces']
        ['port', int, 'The TCP localhost port on which this web app runs']
    ]
}
```

Whenever I need to add new templates or edit existing ones, I can modify them easily and re-build the `etch` binary executable. This means Etch will (hopefully) be a tool I can rely on even as the exact repository layouts and kinds of projects I build evolve over time.

## Usage

Running `etch help` helpfully prints the help message with some usage examples:

```
Etch is a project scaffolding tool.

List all templates:
	etch ls
Information about a template:
	etch info [template]
Create a project from a template:
	etch new [template] [params]

Options
	--dest, -d  The location at which to create the project. $PWD
	            by default.
	--force, -f Overwrite the destination directory even if there are existing
	            files there.
```

As an example, if I were to begin a new web app project called "Persimmon", I may run:

```sh
$ etch new web --name "Persimmon" --slug persimmon --port 10020
Creating dir "lib".
Creating dir "src".
Creating dir "static".
Creating dir "static/css".
Creating dir "static/js".
Creating file "Makefile".
Creating file "README.md".
Creating file "lib/torus.js.oak".
Creating file "src/app.js.oak".
Creating file "src/main.oak".
Creating file "static/css/main.css".
Creating file "static/index.html".
Creating file "static/js/torus.min.js".
Creating file "persimmon.service".
Done.
```

This would result in a filesystem layout like:

```
.
├── Makefile
├── README.md
├── lib
│   └── torus.js.oak
├── persimmon.service
├── src
│   ├── app.js.oak
│   └── main.oak
└── static
    ├── css
    │   └── main.css
    ├── index.html
    └── js
        └── torus.min.js

5 directories, 9 files
```

## Design

One of my goals from the beginning of this project was that Etch should be distributed as a single, statically linked `etch` binary. No extra files or configuration necessary. This meant that all template data had to be "baked in" to the program itself. Some other scaffolding tools, like [Yeoman](https://yeoman.io/), keep their templates installed separately from the scaffolding tool itself. There are benefits to this (the main one being that you can distribute and install templates separately), but those didn't really matter to me as much as the simplicity of "install this, and you're set."

To achieve this "single binary" result, Etch has a build script, `build.oak`. Etch's templates live in a normal folder in the repository, under `./tpl`, written with `{{ placeholders }}` for template variables. At build time, the build script traverses the templates folder and bundles every template file for each template into the program as a dictionary mapping file paths to file contents. When Etch runs, it references this image of the template layout in the filesystem to scaffold out new projects.

To keep things simple, the templates are written using Oak's built-in string interpolation syntax, which looks `'like {{ this }}'`. This currently does mean that templates can't include such format strings without them being stripped out during scaffolding, but I haven't found that to be a big issue in practice.

## Adding a new template

There are two places I need to touch when adding a new template to Etch.

First, I need to tell Etch about the existence of a new template in `config.oak`. Each template entry looks something like this:

```js
web: {
    description: 'Full-stack Oak web application'
    params: [
        ['name', string, 'Name of the project']
        ['slug', string, 'Slug for the project, lowercase & no spaces']
        ['port', int, 'The TCP localhost port on which this web app runs']
    ]
}
```

Most of these properties are self-explanatory. The `params` list should include an ordered list of template parameters that are required by this template. The second item in each parameter entry is a _validation function_ for the value of that parameter specified by the user during scaffolding. For example, the `port` parameter above must be an `int`. The `int` function, when called on a non-integer value, returns `?`, and will stop the scaffolding process early to warn the user about the type mismatch. These validation functions may be arbitrary functions, not simply the built-in type checks, so they may be arbitrarily complex.

Second, I need to add template files under `./tpl`. Each template gets its own sub-directory under `./tpl`, under which are all of that particular template's files and folder layouts. For example, if my new template is called `twitter-bot`, I'd add all of that template's files and folders under `./tpl/twitter-bot`.

After these changes, a `make build` should re-run the entire build and build a version of `etch` with the new template baked-in.

## Build and development

Etch is built with my [Oak programming language](https://oaklang.org), and I manage build tasks with a Makefile.

- `make` or `make build` builds a version of Etch at `./rush`
- `make install` installs Etch to `/usr/local/bin`, because that's where I like to keep my bins
- `make fmt` or `make f` formats all Oak source files tracked by Git
