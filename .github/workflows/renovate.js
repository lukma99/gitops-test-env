module.exports = {
    "$schema": "https://docs.renovatebot.com/renovate-schema.json",
    "extends": [
        "config:base"
    ],
    "platform": "github",
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


