#!/bin/bash

# AI Transcription iOS App - Remote Repository Setup Script
# This script helps you connect your local Git repository to a remote repository

echo "🚀 AI Transcription iOS App - Remote Repository Setup"
echo "=================================================="
echo ""

# Check if we're in a Git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: This directory is not a Git repository."
    echo "Please run this script from the project root directory."
    exit 1
fi

echo "✅ Git repository found!"
echo ""

# Show current status
echo "📊 Current Git Status:"
git status --short
echo ""

# Show commit history
echo "📝 Recent Commits:"
git log --oneline -3
echo ""

echo "🌐 Choose your remote repository platform:"
echo "1) GitHub"
echo "2) GitLab"
echo "3) Bitbucket"
echo "4) Custom URL"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "📋 GitHub Setup Instructions:"
        echo "1. Go to https://github.com"
        echo "2. Click 'New repository'"
        echo "3. Repository name: ai-transcription-ios"
        echo "4. Description: AI-powered transcription and meeting summary iOS app"
        echo "5. Make it Public or Private"
        echo "6. DO NOT initialize with README, .gitignore, or license"
        echo "7. Click 'Create repository'"
        echo ""
        read -p "Enter your GitHub username: " username
        remote_url="https://github.com/$username/ai-transcription-ios.git"
        ;;
    2)
        echo ""
        echo "📋 GitLab Setup Instructions:"
        echo "1. Go to https://gitlab.com"
        echo "2. Click 'New Project'"
        echo "3. Choose 'Create blank project'"
        echo "4. Project name: ai-transcription-ios"
        echo "5. Make it Public or Private"
        echo "6. Click 'Create project'"
        echo ""
        read -p "Enter your GitLab username: " username
        remote_url="https://gitlab.com/$username/ai-transcription-ios.git"
        ;;
    3)
        echo ""
        echo "📋 Bitbucket Setup Instructions:"
        echo "1. Go to https://bitbucket.org"
        echo "2. Click 'Create repository'"
        echo "3. Repository name: ai-transcription-ios"
        echo "4. Make it Public or Private"
        echo "5. Click 'Create repository'"
        echo ""
        read -p "Enter your Bitbucket username: " username
        remote_url="https://bitbucket.org/$username/ai-transcription-ios.git"
        ;;
    4)
        echo ""
        read -p "Enter the full remote repository URL: " remote_url
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "🔗 Setting up remote repository..."
echo "Remote URL: $remote_url"

# Add remote origin
git remote add origin "$remote_url"

# Verify remote was added
if git remote -v | grep -q "origin"; then
    echo "✅ Remote 'origin' added successfully!"
else
    echo "❌ Failed to add remote. Please check the URL and try again."
    exit 1
fi

echo ""
echo "📤 Pushing to remote repository..."

# Push to remote
if git push -u origin main; then
    echo ""
    echo "🎉 SUCCESS! Your AI Transcription iOS app is now on the remote repository!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Visit your remote repository to verify the files"
    echo "2. Set up branch protection rules (recommended)"
    echo "3. Add collaborators if working with a team"
    echo "4. Start developing features using feature branches"
    echo ""
    echo "🔧 Useful commands:"
    echo "  git status                    # Check repository status"
    echo "  git add .                     # Stage all changes"
    echo "  git commit -m 'message'       # Commit changes"
    echo "  git push                      # Push to remote"
    echo "  git pull                      # Pull latest changes"
    echo ""
    echo "📚 For more information, see GIT_SETUP.md"
else
    echo ""
    echo "❌ Failed to push to remote repository."
    echo "Please check:"
    echo "1. The remote repository exists and is accessible"
    echo "2. You have the correct permissions"
    echo "3. The remote URL is correct"
    echo ""
    echo "You can remove the remote and try again with:"
    echo "  git remote remove origin"
    exit 1
fi
