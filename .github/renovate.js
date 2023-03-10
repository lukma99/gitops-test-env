module.exports = {
    // "extends": [
    //     "config:base"
    // ],
    "dependencyDashboard": false,
    "platform": "github",
    "username": "renovate-bot",
    "gitAuthor": "Renovate Bot <renovate@users.noreply.github.com>",
    "repositories": [
        "lukma99/gitops-test-env"
    ],

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