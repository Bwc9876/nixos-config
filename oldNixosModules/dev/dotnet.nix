{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    dotnet-sdk
    dotnet-runtime
    dotnetPackages.Nuget
    # mono
  ];
}
