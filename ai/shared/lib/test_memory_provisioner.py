import os
import tempfile
import unittest

from memory_provisioner import project_key, provision_memory_dir, render_index_context


class MemoryProvisionerTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.public = os.path.join(self.tmp.name, "public")
        self.private = os.path.join(self.tmp.name, "private")
        self.destination = os.path.join(self.tmp.name, "destination")
        os.makedirs(self.public)
        os.makedirs(self.private)
        self.write(self.public, "public.md", "public", "public trigger")
        self.write(self.private, "private.md", "private", "private trigger")

    @staticmethod
    def write(directory, filename, name, description):
        with open(os.path.join(directory, filename), "w", encoding="utf-8") as handle:
            handle.write("---\nname: %s\ndescription: %s\n---\nbody\n" % (name, description))

    def test_public_is_linked_and_private_is_not_spread(self):
        provision_memory_dir(self.destination, self.public, self.private)
        self.assertTrue(os.path.islink(os.path.join(self.destination, "public.md")))
        self.assertFalse(os.path.lexists(os.path.join(self.destination, "private.md")))

    def test_private_is_linked_when_eligibility_copy_exists(self):
        eligibility = os.path.join(self.tmp.name, "eligibility")
        os.makedirs(eligibility)
        open(os.path.join(eligibility, "private.md"), "w").close()
        provision_memory_dir(self.destination, self.public, self.private, eligibility)
        self.assertTrue(os.path.islink(os.path.join(self.destination, "private.md")))

    def test_index_preserves_prose_and_drops_missing_entries(self):
        os.makedirs(self.destination)
        with open(os.path.join(self.destination, "MEMORY.md"), "w", encoding="utf-8") as handle:
            handle.write("intro\n- [gone](gone.md)\n")
        provision_memory_dir(self.destination, self.public, self.private)
        with open(os.path.join(self.destination, "MEMORY.md"), encoding="utf-8") as handle:
            index = handle.read()
        self.assertIn("intro", index)
        self.assertIn("[public](public.md)", index)
        self.assertNotIn("gone.md", index)

    def test_context_contains_index_not_memory_body(self):
        provision_memory_dir(self.destination, self.public, self.private)
        context = render_index_context(self.destination)
        self.assertIn("public trigger", context)
        self.assertNotIn("\nbody\n", context)

    def test_project_key_matches_claude_encoding(self):
        self.assertEqual("-tmp-a-b", project_key("/tmp/a.b"))


if __name__ == "__main__":
    unittest.main()
