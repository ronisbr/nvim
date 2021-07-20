# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   File to run the Julia language server adapted from:
#
#       https://github.com/fredrikekre/.dotfiles/blob/master/.config/nvim/lsp-julia/run.jl
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Load the packages LanguageServer.jl and SymbolServer.jl package from the path
# on this file. Notice that the files Manifest.toml and Project.toml must exist.
# To create them, do:
#
#   julia --project=./ -e "using Pkg; Pkg.add(\"SymbolServer\"); Pkg.add(\"LanguageServer\")"

old_load_path = copy(LOAD_PATH)
push!(empty!(LOAD_PATH), @__DIR__)
using LanguageServer, SymbolServer
append!(empty!(LOAD_PATH), old_load_path)

# Figure out the active project.
project_path = let
    dirname(something(
        # 1. Finds an explicitly set project (JULIA_PROJECT).
        Base.load_path_expand((
            p = get(ENV, "JULIA_PROJECT", nothing);
            p === nothing ? nothing : isempty(p) ? nothing : p
        )),
        # 2. Look for a Project.toml file in the current working directory, or
        #    parent directories, with $HOME as an upper boundary.
        Base.current_project(),
        # 3. First entry in the load path.
        get(Base.load_path(), 1, nothing),
        # 4. Fallback to default global environment, this is more or less
        #    unreachable.
        Base.load_path_expand("@v#.#"),
    ))
end

# Depot path for the server to index (empty uses default).
depot_path = get(ENV, "JULIA_DEPOT_PATH", "")

# Start the server.
@info "Running julia language server" VERSION project_path depot_path
server = LanguageServer.LanguageServerInstance(
    stdin,
    stdout,
    project_path,
    depot_path
)
server.runlinter = true
run(server)
