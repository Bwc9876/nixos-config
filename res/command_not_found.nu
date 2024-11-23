{|cmd_name|
    try {
        let attrs = (nix-locate --minimal --no-group --type x --type s --top-level --whole-name --at-root $"/bin/($cmd_name)")
        let len = (echo $attrs | split row "\n" | length)
    
        if $len == 0 {
            return null
        } else {
            return $"\nThe program ($cmd_name) is not installed, but available from the following location\(s\):\n\n($attrs | str replace ".out" "")"
        }
    }
}