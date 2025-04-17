Latest changes in {{ version }}:
{% endif %}
{% for category, changes in release.changes -%}
{%- for change in changes -%}
{% if change.commitHash|attrs:"Release-Notes" %}
- {{ change.commitHash|attrs:"Release-Notes" }}
{% endif %}
{%- endfor -%}
{%- endfor %}
- Bug fixes and stability improvements
