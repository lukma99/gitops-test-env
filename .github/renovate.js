module.exports = {
    "dependencyDashboard": false,
    "platform": "github",
    "username": "lukma99",
    "gitAuthor": "lukma99 <lukm@mailbox.org>",
    "repositories": [
        "lukma99/gitops-test-env"
    ],
    // 0 means no limit. Otherwise, Renovate Bot can be limited while testing a lot of PRs.
    "prHourlyLimit": 0,
    // parentDir equals to "dev", "staging" or "prod", as the parent dirs in kustomize are called after the stages
    "additionalBranchPrefix": "{{parentDir}}-",
    "commitMessagePrefix": "(Renovate) {{parentDir}}: ",
    "enabledManagers": ["kustomize"],
    // ignore the other release promotion strategies to not interfere in their process
    "kustomize": {
        "ignorePaths": [
            "**/01-manual/**",
            "**/02-ci-pipeline/**",
            "**/03-image-updater/**",
            "**/05-preview-environments/**"
        ]
    }
};
