// .github/workflows/actions/createAndMergePR.js

const core = require('@actions/core');
const github = require('@actions/github');

title, head, base, body

async function run() {
  try {
    const token = core.getInput('token');
    const title = core.getInput('title');
    const head = core.getInput('head');
    const base = core.getInput('base');
    const body = core.getInput('body');

    const octokit = github.getOctokit(token);

    // Create pull request
    const pr = await octokit.pulls.create({
      owner: github.context.repo.owner,
      repo: github.context.repo.repo,
      title: title,
      head: head,
      base: base,
      body: body
    });

    console.log(`Created pull request: ${pr.data.html_url}`);

    // Merge pull request
    const merge = await octokit.pulls.merge({
      owner: github.context.repo.owner,
      repo: github.context.repo.repo,
      pull_number: pr.data.number
    });

    console.log(`Merged pull request: ${merge.status}`);

    // Delete branch
    const deleteBranch = await octokit.git.deleteRef({
      owner: github.context.repo.owner,
      repo: github.context.repo.repo,
      ref: `heads/${head}`
    });

    console.log(`Deleted branch: ${deleteBranch.status}`);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
