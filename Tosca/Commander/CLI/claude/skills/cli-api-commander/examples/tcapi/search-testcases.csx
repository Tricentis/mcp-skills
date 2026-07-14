#r "COMMANDER_HOME\TCAPIObjects.dll"
#r "COMMANDER_HOME\TCAPI.dll"

using Tricentis.TCAPI;
using Tricentis.TCAPIObjects.Objects;

var commanderHome = Environment.GetEnvironmentVariable("COMMANDER_HOME")
    ?? throw new InvalidOperationException("Set COMMANDER_HOME");

Environment.SetEnvironmentVariable("COMMANDER_HOME", commanderHome);

var tws = Args.FirstOrDefault()
    ?? Environment.GetEnvironmentVariable("TOSCA_WORKSPACE")
    ?? throw new InvalidOperationException("Pass workspace .tws as arg or set TOSCA_WORKSPACE");

var user = Environment.GetEnvironmentVariable("TOSCA_USER") ?? "Admin";
var password = Environment.GetEnvironmentVariable("TOSCA_PASSWORD") ?? "";

using var api = TCAPI.CreateInstance();
var workspace = api.OpenWorkspace(tws, user, password);
var project = workspace.GetProject();

foreach (var tc in project.Search("=>SUBPARTS:TestCase"))
    Console.WriteLine($"{tc.Name}  {tc.NodePath}");

workspace.Save();
api.CloseWorkspace();
