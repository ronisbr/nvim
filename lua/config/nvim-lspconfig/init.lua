-- Plugin configuration: nvim-lspconfig
-- ============================================================================

local nvim_lsp = require('lspconfig')
local util = require('lspconfig/util')

-- Do not show virtual text since we are using lspsaga.
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false
    }
)

-- =============================================================================
--                                   Julia
-- =============================================================================

-- To use Julia LSP, execute the following command:
--     julia --project=@nvim-lspconfig
--     ]
--     add CSTParser#master LanguageServer#master StaticLint#master SymbolServer#master PackageCompiler
--     using Pkg, PackageCompiler
--     create_sysimage(
--         :LanguageServer,
--         sysimage_path = dirname(Pkg.Types.Context().env.project_file) * "/languageserver.so"
--     )

-- NOTE: The new configuration of root_dir is not compatible with single file
-- If we use the default configuration of `root_dir`, then we have problems when
-- running Julia LSP using single file mode (without a project).

nvim_lsp.julials.setup({
  cmd = {
    'julia',
    '-J' .. vim.fn.getenv("HOME") .. '/.julia/environments/nvim-lspconfig/languageserver.so',
    '--sysimage-native-code=yes',
    '--startup-file=no',
    '--history-file=no',
    '-e',
    [[
        # Load LanguageServer.jl: attempt to load from
        #     ~/.julia/environments/nvim-lspconfig
        # with the regular load path as a fallback.
        ls_install_path = joinpath(
            get(DEPOT_PATH, 1, joinpath(homedir(), ".julia")),
            "environments",
            "nvim-lspconfig"
        )
        pushfirst!(LOAD_PATH, ls_install_path)
        using LanguageServer
        popfirst!(LOAD_PATH)

        depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
        project_path = let
            dirname(something(
                # 1. Finds an explicitly set project (JULIA_PROJECT)
                Base.load_path_expand((
                    p = get(ENV, "JULIA_PROJECT", nothing);
                    p === nothing ? nothing : isempty(p) ? nothing : p
                )),

                # 2. Look for a Project.toml file in the current working directory,
                #     or parent directories, with $HOME as an upper boundary.
                Base.current_project(),

                # 3. First entry in the load path
                get(Base.load_path(), 1, nothing),

                # 4. Fallback to default global environment, this is more or less
                #     unreachable
                Base.load_path_expand("@v#.#"),
            ))
        end

        @info "Running language server" VERSION pwd() project_path depot_path
        server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
        server.runlinter = true
        run(server)
  ]]},

  root_dir = function(fname)
    return util.root_pattern 'Project.toml'(fname) or
           util.find_git_ancestor(fname) or
           util.path.dirname(fname)
  end,
})

-- =============================================================================
--                                    C++
-- =============================================================================

-- To use C++ LSP, the software `ccls` must be installed.
nvim_lsp.ccls.setup({ })
