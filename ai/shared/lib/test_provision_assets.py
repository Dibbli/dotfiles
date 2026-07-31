import os
import pathlib
import sys
import tempfile
import tomllib
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import provision_assets


ROOT = pathlib.Path(__file__).resolve().parents[2]
AGENT_NAMES = {
    "code-reviewer",
    "comment-analyzer",
    "pr-test-analyzer",
    "silent-failure-hunter",
    "type-design-analyzer",
}


class ProvisionAssetsTest(unittest.TestCase):
    def test_shared_skill_and_codex_agent_links_are_idempotent(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory, "root")
            home = pathlib.Path(directory, "home")
            skill = root / "codex/skills/fix/SKILL.md"
            agent = root / "codex/agents/code-reviewer.toml"
            unmanaged = home / ".codex/agents/unmanaged.toml"
            for path in (skill, agent, unmanaged):
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(path.name)

            old_root, old_home = provision_assets.ROOT, provision_assets.HOME
            provision_assets.ROOT, provision_assets.HOME = str(root), str(home)
            self.addCleanup(setattr, provision_assets, "ROOT", old_root)
            self.addCleanup(setattr, provision_assets, "HOME", old_home)

            self.assertEqual(2, provision_assets.provision())
            codex_skill = home / ".codex/skills/fix/SKILL.md"
            codex_agent = home / ".codex/agents/code-reviewer.toml"
            # Codex ignores symlinks, so its assets must be real files with the source content.
            self.assertFalse(codex_skill.is_symlink())
            self.assertEqual("SKILL.md", codex_skill.read_text())
            self.assertFalse(codex_agent.is_symlink())
            self.assertEqual("code-reviewer.toml", codex_agent.read_text())
            self.assertEqual(0, provision_assets.provision())
            self.assertEqual("unmanaged.toml", unmanaged.read_text())

    def test_codex_skill_symlink_is_replaced_with_a_real_file(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory, "root")
            home = pathlib.Path(directory, "home")
            skill = root / "codex/skills/fix/SKILL.md"
            skill.parent.mkdir(parents=True, exist_ok=True)
            skill.write_text("real content")
            stale = home / ".codex/skills/fix/SKILL.md"
            stale.parent.mkdir(parents=True, exist_ok=True)
            stale.symlink_to(skill)  # the old, invisible-to-Codex deploy

            old_root, old_home = provision_assets.ROOT, provision_assets.HOME
            provision_assets.ROOT, provision_assets.HOME = str(root), str(home)
            self.addCleanup(setattr, provision_assets, "ROOT", old_root)
            self.addCleanup(setattr, provision_assets, "HOME", old_home)

            self.assertEqual(1, provision_assets.provision())
            self.assertFalse(stale.is_symlink())
            self.assertEqual("real content", stale.read_text())

    def test_codex_review_agents_are_read_only_and_structured(self):
        paths = sorted((ROOT / "codex/agents").glob("*.toml"))
        self.assertEqual(AGENT_NAMES, {path.stem for path in paths})
        for path in paths:
            with path.open("rb") as handle:
                config = tomllib.load(handle)
            instructions = config["developer_instructions"]
            self.assertEqual(path.stem, config["name"])
            self.assertEqual("read-only", config["sandbox_mode"])
            self.assertTrue(config["description"])
            self.assertIn("Do not edit", instructions)
            self.assertIn("severity", instructions)
            self.assertIn("ease", instructions)

    def test_fix_skill_contains_the_review_contract(self):
        text = (ROOT / "codex/skills/fix/SKILL.md").read_text()
        required = (
            "name: fix",
            "git status --porcelain",
            "frozen diff",
            "code-reviewer",
            "comment-analyzer",
            "pr-test-analyzer",
            "silent-failure-hunter",
            "type-design-analyzer",
            "introduced by this diff",
            "noblame",
            "confidence",
            "ease",
            "No fixes needed.",
            "do not edit",
        )
        for phrase in required:
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, text)

    def test_mr_skill_contains_the_review_contract(self):
        text = (ROOT / "codex/skills/mr/SKILL.md").read_text()
        required = (
            "name: mr",
            "git status --porcelain",
            "frozen diff",
            "code-reviewer",
            "comment-analyzer",
            "pr-test-analyzer",
            "silent-failure-hunter",
            "type-design-analyzer",
            "this diff introduced it",
            "confidence",
            "ease",
            "Nincs jelzés.",
            "Komment-észrevételek:",
            "do not edit",
        )
        for phrase in required:
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, text)


if __name__ == "__main__":
    unittest.main()
