import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext): void {
  context.subscriptions.push(
    vscode.commands.registerCommand('cli-api-commander.showInstallGuide', async () => {
      const doc = await vscode.workspace.openTextDocument({
        content: [
          '# Tosca Commander IDE Integration',
          '',
          'Run from the IDE integration zip (user scope, no admin):',
          '',
          '```powershell',
          '.\\Install-CliApiCommanderPack.ps1 -Ide VSCode -Scope Project',
          '```',
          '',
          'See: https://github.com/Tricentis-Tosca/Tosca.Commander.IDE.integration',
        ].join('\n'),
        language: 'markdown',
      });
      await vscode.window.showTextDocument(doc);
    })
  );
}

export function deactivate(): void {}
