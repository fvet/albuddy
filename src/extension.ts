import * as vscode from "vscode";

const EXTENSION_ID = "FredericVercaemst.albuddy";

export function activate(context: vscode.ExtensionContext): void {
  const output = vscode.window.createOutputChannel("AL Buddy");
  context.subscriptions.push(output);

  const version =
    (vscode.extensions.getExtension(EXTENSION_ID)?.packageJSON as { version?: string } | undefined)
      ?.version ?? "unknown";

  output.appendLine(`AL Buddy ${version} activated.`);

  context.subscriptions.push(
    vscode.commands.registerCommand("albuddy.showVersion", () => {
      void vscode.window.showInformationMessage(`AL Buddy version ${version}`);
    }),
  );
}

export function deactivate(): void {
  // Nothing to clean up yet.
}
