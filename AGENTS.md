# Context for coding agents

This file provides guidance to coding agents when working with code in this repository.

## About AlchemyCMS

AlchemyCMS is an open source Rails CMS engine with a flexible, YAML-driven content architecture. It uses a three-tier content model: Pages → Elements → Ingredients, with multi-language support, versioning, and a modern admin interface built with Rails + Web Components.

## Development Commands

### Initial Setup

```bash
bin/setup
```

This installs dependencies (Ruby gems + Bun packages) and sets up the dummy app in `spec/dummy/`.

### Running Tests

```bash
# Run all tests (prepares database + runs RSpec suite)
bundle exec rake

# Run RSpec only
bin/rspec

# Run specific test file
bin/rspec spec/models/alchemy/page_spec.rb

# Prepare test database (required before first test run)
bundle exec rake alchemy:spec:prepare

# Run JavaScript tests
bun run test
```

### Building Frontend Assets

```bash
# Build all assets (JavaScript, CSS, Handlebars templates, icons)
bun run build

# Build individual components
bun run build:js         # Rollup JavaScript bundling
bun run build:css        # Sass compilation
bun run handlebars:compile  # Compile Handlebars templates
bun run build:icons      # Generate icon sprite
```

### Running the Dummy App

```bash
# Start the development server (runs spec/dummy/bin/dev)
bin/start
```

This starts a Rails server and bun watch task in the dummy application for running a full dev environment.

### Starting the Rails console

```bash
cd spec/dummy; bin/rails console; cd -
```

This starts the Rails console for running code in the context of the dummy application.

### Running a one off script

```bash
cd spec/dummy; bin/rails runner 'puts Some.ruby.code'; cd -
```

This starts the Rails console for running code in the context of the dummy application.

### Linting

```bash
# Ruby linting (uses Standard/RuboCop)
bundle exec standardrb

# JavaScript linting
bun run eslint

# Prettier linting
bun run lint
```

### Code Formatting

```bash
# Ruby linting (uses Standard/RuboCop)
bundle exec standardrb --fix

# Prettier formatting
bun run prettier --write app/javascript/**/*.js
```

## Architecture Overview

### Content Model: Three-Tier Hierarchy

Alchemy organizes content in a three-tier hierarchy:

**Pages** (`Alchemy::Page`)
- Top-level content containers organized in a tree structure (using `awesome_nested_set`)
- Each page has a `page_layout` (defined in `config/alchemy/page_layouts.yml`)
- Multi-language support: each page belongs to one `Alchemy::Language`
- **Dual-version system**:
  - `draft_version` - Working copy (no `public_on` date)
  - `public_version` - Published content (has `public_on` date)
- Page locking prevents concurrent editing (`locked_by`, `locked_at`)

**Elements** (`Alchemy::Element`)
- Content blocks that live on specific `PageVersion` records
- Defined in `config/alchemy/elements.yml`
- Can be **fixed** (permanent) or **mutable** (user-removable)
- Support nesting via `parent_element_id`
- Positioned using `acts_as_list` within scope

**Ingredients** (`Alchemy::Ingredient`)
- The actual content values (text, images, links, etc.)
- Uses **Single Table Inheritance (STI)** with 15+ types:
  - Value types: `Text`, `Headline`, `Html`, `Richtext`, `Number`, `Boolean`
  - Media types: `Picture`, `File`, `Audio`, `Video`
  - Reference types: `Page`, `Node`, `Link`
  - Special types: `Select`, `Datetime`
- Each has a `role` (semantic identifier within element) and optional `related_object` (polymorphic)
- Flexible metadata stored in JSON `data` column

### YAML-Driven Configuration

Alchemy uses declarative YAML definitions that are **separate from database records**:

- `config/alchemy/page_layouts.yml` - Page layout definitions
- `config/alchemy/elements.yml` - Element definitions with ingredient specs
- Definition classes (`PageDefinition`, `ElementDefinition`, `IngredientDefinition`) are read-only configuration objects

This separation allows runtime configuration changes without database migrations.

### Key Model Relationships

```
Site
└── languages (Alchemy::Language)
    └── pages (Alchemy::Page - nested set tree)
        └── versions (Alchemy::PageVersion)
            └── elements (Alchemy::Element - can be nested)
                └── ingredients (Alchemy::Ingredient - STI)
                    └── related_object (polymorphic: Picture, Page, etc.)
```

### Navigation System

**Nodes** (`Alchemy::Node`) represent menu/navigation structure separate from page hierarchy:
- Also uses nested set pattern per language
- Can attach to pages or link to external URLs
- Referenced by elements via `Ingredients::Node`

### Service Objects

Complex business logic is extracted into service classes in `app/services/alchemy/`:

- `CopyPage` - Deep copies pages with all elements and ingredients
- `DuplicateElement` - Element copying with ingredient awareness
- `PageTreePreloader` - Optimizes page tree loading to prevent N+1 queries
- `DeleteElements` - Batch deletion with recursive nested element handling

Use service objects for complex operations rather than bloating models.

## Frontend Architecture

### Build System

- **JavaScript**: Rollup for bundling (see `rollup.config.mjs`)
- **CSS**: Sass with compression
- **Package Manager**: Bun (modern npm alternative)
- **Templates**: Handlebars for client-side rendering

### JavaScript Patterns

The admin interface uses a **hybrid architecture**:

**Legacy jQuery** (still used for):
- Select2 dropdowns
- Event delegation
- AJAX operations

**Modern Web Components** (preferred for new features):
- Custom elements in `app/javascript/alchemy_admin/components/`
- Base class: `AlchemyHTMLElement` (extends `HTMLElement`)
- Examples: `alchemy-sitemap`, `alchemy-element-editor`, `alchemy-datepicker`
- Vanilla JavaScript (no framework dependency)

**Rails Integration**:
- Turbo for navigation (replacing Turbolinks)
- Rails UJS for legacy forms (new forms should prefer Turbo Frames)
- Custom events: `Alchemy.${name}` namespace
- View Component: Used to populate Ruby values into custom JS elements.

**Global Object**: `window.Alchemy` provides legacy utilities:
```javascript
Alchemy.t()          // i18n translation
Alchemy.growl()      // Notifications
Alchemy.LinkDialog   // Link picker
Alchemy.closeCurrentDialog()
```

Always prefer local imports for global usage where possible.

### ViewComponents

Admin UI uses Rails ViewComponents for rendering:
- Each ingredient type has two components:
  - `*_editor.rb` - Form in admin UI
  - `*_view.rb` - Frontend rendering
- Located in `app/components/alchemy/ingredients/`

## Testing Patterns

### Test Structure

```
spec/
├── models/        # Model unit tests
├── features/      # System tests (Capybara with JavaScript)
├── controllers/   # Controller specs
├── requests/      # API/routing specs
├── components/    # ViewComponent specs
├── javascript/    # Frontend tests (Vitest)
└── support/       # Shared helpers and matchers
```

### Tools

- **RSpec** with Rails integration
- **FactoryBot** for test data (`create(:alchemy_page)`)
- **Capybara** for browser automation (with Selenium for JS tests)
- **Shoulda Matchers** for ActiveRecord assertions
- **WebMock** for HTTP stubbing
- **SimpleCov** for coverage
- **Vitest** for JavaScript unit tests

### Shared Examples

Use shared examples for consistent testing across similar classes:
- `shared_ingredient_examples` - Common ingredient behavior
- `shared_ingredient_editor_examples` - Admin form tests
- `having_picture_thumbnails_examples` - Picture variant tests

### Thread-Local State

Use `Alchemy::Current` for thread-safe context:
```ruby
Alchemy::Current.language = language
Alchemy::Current.site = site
Alchemy::Current.preview_page = page
```

## Code Style & Conventions

Follow Ruby and JavaScript conventions from `CONTRIBUTING.md`:

**Ruby**:
- Two spaces, no tabs
- Prefer `&&`/`||` over `and`/`or`
- Use `->` over `lambda`
- Ruby 1.9+ hash syntax: `{a: 'b'}`
- Run `bundle exec standardrb --fix` before committing

**JavaScript**:
- Use Prettier for formatting
- Custom elements should extend `HTMLElement`
- Event-driven communication between components
- Prefer modern ES6+ syntax

**Commit Messages**:
- Do not use bullet points in commit message bodies
- Write short explanatory sentences that explain why the change is useful or necessary
- Focus on the reasoning and context, not just listing what changed
- Keep commits focused on a single topic. Unrelated changes must go in separate commits

## Important Patterns

### Definition Repositories

Layouts and elements can use custom definition repositories:
```ruby
Alchemy::Page.layouts_repository = CustomClass
Alchemy::Element.definitions_repository = CustomClass
```

### Nested Set Operations

Pages and nodes use `awesome_nested_set` for tree hierarchies:
- Efficient querying: `page.ancestors`, `page.descendants`, `page.subtree`
- Avoid manual parent_id manipulation
- Use scoped queries: `Alchemy::Page.where(language: lang)`

### Versioning Workflow

When working with page content:
- Authors edit `page.draft_version`
- Publishing sets `public_on` datetime on version
- Readers always see `page.public_version`
- Never modify published versions directly

### Custom Ingredient Types

Create new ingredient types by:
1. Subclass `Alchemy::Ingredient` in `app/models/alchemy/ingredients/`
2. Add view component in `app/components/alchemy/ingredients/`
3. Add editor component for admin UI
4. Register in element YAML definitions

## Upgrading Alchemy

After updating the gem:
```bash
bundle update alchemy_cms
bin/rake alchemy:upgrade
```

This runs automated upgrade tasks. Read the output carefully for manual steps.

## File Locations

- **Models**: `app/models/alchemy/`
- **Controllers**: `app/controllers/alchemy/admin/` (admin), `app/controllers/alchemy/` (frontend)
- **Views**: `app/views/alchemy/admin/`, `app/views/alchemy/`
- **Components**: `app/components/alchemy/` (ViewComponents)
- **JavaScript**: `app/javascript/alchemy_admin/`
- **Stylesheets**: `app/stylesheets/alchemy/`
- **Services**: `app/services/alchemy/`
- **Serializers**: `app/serializers/alchemy/` (API responses)
- **Jobs**: `app/jobs/alchemy/`
- **Lib**: `lib/alchemy/` (core engine code)
- **Config**: `config/alchemy/` (YAML definitions)
- **Generators**: `lib/generators/alchemy/`

## Resources

- Documentation: https://guides.alchemy-cms.com
- API Docs: https://www.rubydoc.info/github/AlchemyCMS/alchemy_cms
- Issues: https://github.com/AlchemyCMS/alchemy_cms/issues
- Slack: https://alchemy-cms.slack.com
