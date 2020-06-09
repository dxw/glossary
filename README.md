# dxw Glossary Generator

This takes the [dxw Glossary
Spreadsheet](https://docs.google.com/spreadsheets/d/1CHJA8fJIU85iCpcx4s-gc9IXqq7DLTxbjNetH_dSMqQ/)
and turns it into a hosted, cross-linked [glossary of terms and
acronyms](https://dxw.github.io/glossary/).

## Description

The application is a single ruby script in `build.rb`.

## Installation

1. Install prerequisites by running `bundle install`.
1. Copy the `.env.example` file to `.env`, and add a JSON string representing a
   Google Service Account with access to the spreadsheet. These details are
   available in 1Password under "Glossary Spreadsheet Service Account".

## Building

Build the glossary by running:

`bundle exec ruby build.rb`

The output will be rendered to the `dist` directory.

### View the output

You can view the output by looking at the generated HTML files in your web
browser, for example with:

`open dist/index.html`
