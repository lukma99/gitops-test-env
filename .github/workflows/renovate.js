module.exports = {
    "$schema": "https://docs.renovatebot.com/renovate-schema.json",
    "extends": [
        "config:base"
    ],
    "platform": "github",
    "username": "renovate-bot",
    "gitAuthor": "Renovate Bot",
    "onboarding": "false",
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


