# Create and Edit Notes

MkDocs is a static documentation site, so new notes are created by adding Markdown files in the `docs/` folders.

## Quick Start

1. Open your docs folder: `/home/nutanix/ntnxlabs/mkdocs/docs`
2. Pick a location:
   - `meetings/` for meeting notes
   - `guides/` for how-to notes
   - `runbooks/` for operations notes
3. Create a new file ending in `.md`
4. Paste content from a template and save

## Fastest Way to Create a Meeting Note

```bash
cp /home/nutanix/ntnxlabs/mkdocs/docs/doc-templates/meeting-notes-template.md \
   /home/nutanix/ntnxlabs/mkdocs/docs/meetings/2026-06-22-team-sync.md
```

Then edit the new file and replace placeholder values.

## Edit an Existing Note

1. Open any `.md` file under `docs/`
2. Make changes and save
3. Refresh the site (it auto-reloads while `docker compose up` is running)

## Add the Note to Navigation

Edit `mkdocs.yml` and add your note under the right section:

```yaml
nav:
  - Meetings:
      - 2026-06-22 Team Sync: meetings/2026-06-22-team-sync.md
```

If you skip this step, the file can still exist but may be harder to discover from the menu.
