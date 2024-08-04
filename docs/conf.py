# Configuration file for the Sphinx documentation builder.
#
# https://samnicholls.net/2016/06/15/how-to-sphinx-readthedocs/
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'zigi'
copyright = 'H.B. Kuiper'
author = 'H.B. Kuiper'
release = '3.21'
version = release

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['sphinx.ext.intersphinx', 'sphinx.ext.autosectionlabel', 'sphinx.ext.autodoc', 'sphinx.ext.coverage', 'sphinx.ext.napoleon', 'sphinx_markdown_builder', 'sphinx_search.extension', 'sphinxcontrib.jquery']

templates_path = ['_templates']
exclude_patterns = ['build/*', '_build', 'Thumbs.db', '.DS_Store']

import sphinx_rtd_theme
rtd_sphinx_search_file_type = 'minified'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme_path = [sphinx_rtd_theme.get_html_theme_path()]
html_theme = 'sphinx_rtd_theme'
ihtml_static_path = ['_static']
# -- Options for markdown output -------------------------------------------------

# remove .md to ensure links work on github's Wiki
# markdown_http_base = ""
# markdown_uri_doc_suffix = ""


# -- autodoc configuration options ----------------------------------------------
autodoc_member_order = 'bysource'
import sys, os

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
sys.path.insert(0, os.path.abspath('.'))
sys.path.insert(0, os.path.abspath('../src'))
