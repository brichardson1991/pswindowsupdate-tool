@{
    # Information-level findings are style hints; only errors and warnings fail the build.
    Severity     = @('Error', 'Warning')

    ExcludeRules = @(
        # This is an interactive console menu, so Write-Host is the right tool.
        'PSAvoidUsingWriteHost'
    )
}
