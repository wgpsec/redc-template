# Userdata Templates

Specialized template directory containing user data script templates for custom deployment.

## Directory Structure

Each template directory contains:

```
<template-name>/
├── case.json    # Template metadata
└── userdata    # User data script content
```

## case.json Field Description

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | Template name (unique English identifier) |
| nameZh | string | Yes | Chinese name |
| type | string | Yes | Script type: `bash` or `powershell` |
| category | string | Yes | Category: `basic` (Basic), `ai` (AI scenarios) |
| user | string | Yes | Author username |
| version | string | Yes | Version number in format: `x.y.z` |
| url | string | No | Official website |
| description | string | No | Description |
| installNotes | string | No | Post-installation notes |

## Usage

Use through the "Specialized Modules" feature in RedC GUI:

1. Open RedC GUI
2. Go to "Specialized Modules" page
3. Select the corresponding tab (e.g., "AI Scenarios")
4. Select a template and copy for use
