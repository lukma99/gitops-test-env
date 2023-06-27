module.exports = {
    // "extends": [
    //     "config:base"
    // ],
    "dependencyDashboard": false,
    "platform": "github",
    "username": "lukma99",
    "gitAuthor": "lukma99 <lukm@mailbox.org>",
    "repositories": [
        "lukma99/gitops-test-env"
    ],
    "additionalBranchPrefix": "{{parentDir}}-",
    "commitMessagePrefix": "(Renovate) {{parentDir}}: ",
    "enabledManagers": ["kustomize"],
    "kustomize": {
        "ignorePaths": [
            "**/01-manual/**",
            "**/02-ci-pipeline/**",
            "**/03-image-updater/**",
            "**/05-preview-environments/**"
        ]
    }
};
