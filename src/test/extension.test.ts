import * as assert from "node:assert";
import * as vscode from "vscode";

const EXTENSION_ID = "FredericVercaemst.albuddy";

suite("AL Buddy", () => {
  test("the extension is installed", () => {
    assert.ok(
      vscode.extensions.getExtension(EXTENSION_ID),
      `expected ${EXTENSION_ID} to be present`,
    );
  });

  test("the extension activates", async () => {
    const extension = vscode.extensions.getExtension(EXTENSION_ID);
    assert.ok(extension);
    await extension.activate();
    assert.strictEqual(extension.isActive, true);
  });

  test("the Show Version command is registered", async () => {
    const commands = await vscode.commands.getCommands(true);
    assert.ok(
      commands.includes("albuddy.showVersion"),
      "expected albuddy.showVersion to be registered",
    );
  });
});
