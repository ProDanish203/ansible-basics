# Ansible

Ansible is an open-source automation tool that manages IT infrastructure, application deployment, and configuration management using simple YAML playbooks. It operates agentlessly over SSH, allowing you to automate repetitive tasks across multiple servers without installing additional software on target machines.

![Ansible](/images/ansible.jpg)

### Installing Ansible on local machine

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

ansible uses a declarative approach to configure systems by writing explicit yaml configuration files.

## Ansible Architecture

Ansible follows a simple push-based architecture where a control node manages multiple target hosts without requiring agents on remote systems.

![Ansible Architecture](/images/ansible-architecture.png)

### Core Components

**Control Node**: The machine where Ansible is installed and playbooks are executed from. It connects to managed nodes via SSH and pushes configurations.

**Managed Nodes**: Target servers that Ansible configures. No Ansible software needs to be installed on these hosts - they just need SSH access and Python.

**Inventory**: File or directory containing information about managed hosts, including IP addresses, connection details, and host groupings.

**Modules**: Python scripts that perform specific tasks (install packages, manage services, copy files, etc.). Modules are pushed to managed nodes, executed, then removed.

**Playbooks**: YAML files containing ordered lists of tasks to execute on managed hosts. They define the desired state of your infrastructure.

### How It Works

- Control node reads inventory and playbook
- Establishes SSH connections to managed nodes
- Transfers and executes modules on target hosts
- Collects results and provides feedback
- No persistent agents or daemons required on managed nodes
- Uses existing SSH infrastructure for secure communication

This agentless design makes Ansible lightweight and easy to deploy compared to other automation tools.

### File Structure

- **Inventory file**: Contains machine IP addresses and SSH information for remote access
- **Playbook (main.yaml)**: Contains declarative steps for Ansible to execute
- **ansible.cfg**: Configuration file for Ansible settings (optional)

## Some Essential Ansible commands

```bash
# Run playbook
ansible-playbook playbook.yml

# Run with specific inventory
ansible-playbook -i inventory.yml playbook.yml

# Testing connectivity
ansible all -m ping                              # Ping all hosts
ansible webservers -m ping                       # Ping specific group

# Inventory management
ansible-inventory --list                         # List all hosts
ansible-inventory --list --limit webservers      # List hosts in specific group

# Dry run (check mode)
ansible-playbook playbook.yml --check

# Verbose output
ansible-playbook playbook.yml -v                 # -v, -vv, -vvv for more detail
```

## Ansible Handlers

Ansible handlers are special tasks that run only when triggered by other tasks, typically used for actions like restarting services after configuration changes. They ensure operations happen only when necessary, not on every playbook run.

### Handler Execution Flow:

1. Tasks run in order
2. If a task changes something, it "notifies" the handler
3. All tasks complete first
4. Handlers run at the end, only once each
5. Handlers run in the order they're defined

This makes Ansible playbooks more efficient and prevents unnecessary service disruptions!

## Variables

Variables in Ansible are placeholders that store values like server names, configurations, or passwords. They make playbooks reusable and flexible by allowing you to change values without modifying the playbook code. Variables enable dynamic configuration management across different environments and hosts.

## Variable Precedence in Ansible (Low to High Priority)

```bash
# Role defaults
# roles/webserver/defaults/main.yml
apache_port: 80

# Inventory group vars
# group_vars/webservers.yml
apache_port: 8080

# Inventory host vars
# host_vars/web1.yml
apache_port: 8081

# Playbook vars
# playbook.yml
vars:
  apache_port: 8082

# Role vars
# roles/webserver/vars/main.yml
apache_port: 8083

# Block vars
# Within playbook block
- block:
    vars:
      apache_port: 8084

# Task vars
# Within task
- name: Configure Apache
  vars:
    apache_port: 8085

# set_fact/register
- set_fact:
    apache_port: 8086

# Extra vars (highest priority)
ansible-playbook playbook.yml -e "apache_port=8087"
```

## Command Line Variable Assignment

```bash
# Single variable
ansible-playbook playbook.yml -e "env=production"

# Multiple variables
ansible-playbook playbook.yml -e "env=prod debug=true"

# JSON format
ansible-playbook playbook.yml -e '{"env":"prod","port":8080}'

# From file
ansible-playbook playbook.yml -e "@vars.yml"

# YAML format
ansible-playbook playbook.yml -e "env: production"
```

## Environment Variables:

Shell variables that are available to commands, scripts, and processes running on the target system.

## Difference between Variables and Environment Variables

- **Ansible Variables** are internal to Ansible - used for templating, conditionals, and passing data between tasks within playbooks.
- **Environment Variables** are external - they're actual shell environment variables that your commands and scripts can access using `$VARIABLE_NAME`.

Use Ansible variables for Ansible logic and configuration, use environment variables when you need to pass values to shell commands, scripts, or applications running on the target system.

```bash
---
- name: Quick Comparison
  hosts: all
  vars:
    app_name: "myapp"           # Ansible variable
    config_path: "/etc/myapp"   # Ansible variable

  environment:
    APP_NAME: "{{ app_name }}"  # Environment variable (uses Ansible var)
    CONFIG_PATH: "/etc/myapp"   # Environment variable

  tasks:
    # Ansible variable usage
    - name: Create directory using Ansible variable
      file:
        path: "{{ config_path }}"  # ✅ Ansible variable in module
        state: directory

    # Environment variable usage
    - name: Run script that needs environment variables
      shell: |
        echo "App: $APP_NAME"           # ✅ Environment variable in shell
        mkdir -p $CONFIG_PATH/logs      # ✅ Environment variable in shell
      register: output
```

## Conditionals

**Conditionals** in Ansible allow you to control task execution based on specific conditions - like running tasks only on certain OS types, when variables have specific values, or when previous tasks succeed/fail.

### Key Components

- **`when:`** - Primary conditional statement
- **`ansible_facts`** - System information (OS, hardware, network, etc.)
- **`failed`, `succeeded`, `changed`** - Task result states
- **`is defined`, `is not defined`** - Variable existence checks
- **Logical operators**: `and`, `or`, `not`

## Templating in Ansible

**Templating** in Ansible allows you to create dynamic configuration files by inserting variables, conditionals, and loops into template files. It enables you to generate customized files for different hosts or environments from a single template source.

### Jinja2 Templating

**Jinja2** is the templating engine used by Ansible - it's a Python-based template language that uses `{{ }}` for variables, `{% %}` for logic (loops, conditionals), and `{# #}` for comments. It's used to make templates dynamic and reusable instead of having static configuration files.

## Ansible Modules

Modules are reusable units of code that Ansible uses to perform specific tasks. They're the building blocks of Ansible playbooks.

## Ansible Roles

Roles are a way to organize playbooks and reuse code. They provide a structured way to group tasks, variables, files, and templates.

```bash
# Role Structure
roles/
└── webserver/
    ├── tasks/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    ├── templates/
    ├── files/
    ├── vars/
    │   └── main.yml
    ├── defaults/
    │   └── main.yml
    └── meta/
        └── main.yml


 # Using Roles
- name: Configure web servers
  hosts: webservers
  roles:
    - webserver
    - database
    - { role: nginx, nginx_port: 8080 }
```

## Deployment Strategies

Method of rolling out applications/configurations across multiple servers - can be all-at-once, rolling updates, or canary deployments to minimize downtime and risk.

### Blue-Green Strategy

Maintain two identical production environments (blue=current, green=new) - deploy to green, test it, then switch traffic from blue to green for zero-downtime deployments.

### Common Ansible Deployment Strategies

- **Rolling Deployment**: Update servers one by one or in small batches to maintain service availability during updates.
- **All-at-Once**: Deploy to all servers simultaneously - fastest but causes downtime if issues occur.
- **Canary Deployment**: Deploy to a small subset of servers first, monitor for issues, then gradually roll out to remaining servers.

The `--limit` flag restricts playbook execution to specific hosts or groups from your inventory.

```bash
ansible-playbook -i inventory.yaml playbook.yaml --limit blue
# Runs only on blue group

ansible-playbook -i inventory.yaml playbook.yaml --limit green
# Runs only on green group
```

## Error Handling in Ansible

**Error Handling** in Ansible allows you to control what happens when tasks fail - you can ignore errors, retry failed tasks, or define custom failure conditions instead of stopping the entire playbook.

### Key Error Handling Methods

**`ignore_errors`**: Continue playbook execution even if task fails
**`failed_when`**: Define custom failure conditions

**`rescue/always`**: Handle errors with try-catch-like blocks
**`retry/until`**: Retry tasks until they succeed or max attempts reached

## Ansible Vault

**Ansible Vault** is a built-in encryption feature that allows you to encrypt sensitive data like passwords, API keys, and certificates in your playbooks and variable files, keeping them secure while stored in version control.

```bash
# File operations
ansible-vault create secrets.yaml                    # Create new encrypted file
ansible-vault encrypt vars.yaml                      # Encrypt existing file
ansible-vault decrypt secrets.yaml                   # Decrypt file (makes readable)
ansible-vault view secrets.yaml                      # View encrypted file without decrypting
ansible-vault edit secrets.yaml                      # Edit encrypted file
ansible-vault rekey secrets.yaml                     # Change vault password

# String Operations
ansible-vault encrypt_string 'mysecret'             # Encrypt single string
ansible-vault encrypt_string 'mysecret' --name 'db_pass'  # Encrypt string with variable name

# Running Playbooks with Vault
ansible-playbook playbook.yml -e vault.yaml --ask-vault-pass      # Prompt for vault password
ansible-playbook playbook.yml --ask-vault-pass      # Prompt for vault password
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass  # Use password file
ansible-playbook playbook.yml --vault-id dev@~/.vault_dev  # Use labeled vault

# Password File Management
echo 'mypassword' > ~/.vault_pass                   # Create password file
chmod 600 ~/.vault_pass                             # Secure password file permissions

# Multiple Vault IDs
ansible-vault create secrets.yml --vault-id prod@prompt     # Create with specific vault ID
ansible-vault view secrets.yml --vault-id prod@~/.vault_prod  # View with specific vault ID
ansible-playbook site.yml --vault-id dev@~/.vault_dev --vault-id prod@~/.vault_prod  # Multiple vaults
```

## Best Practices

### Playbook Organization

- Use meaningful names for tasks and playbooks
- Group related tasks in roles
- Keep playbooks idempotent (safe to run multiple times)
- Use tags for selective execution

### Security

- Always use Ansible Vault for sensitive data
- Use SSH keys instead of passwords
- Limit inventory file permissions
- Don't commit unencrypted secrets to version control

### Performance

- Use `gather_facts: no` when facts aren't needed
- Limit host connections with `serial` or `throttle`
- Use `async` for long-running tasks
- Cache fact gathering when possible

### Variables and Inventory

- Use group_vars and host_vars for organization
- Follow consistent naming conventions
- Document variable purposes
- Use defaults in roles

## Conclusion

Ansible is a powerful automation tool that simplifies infrastructure management through its agentless architecture and declarative YAML syntax. The key to mastering Ansible is understanding its core concepts: playbooks for orchestration, variables for flexibility, templates for dynamic configuration, and roles for code organization.

Start with simple tasks and gradually build more complex automation workflows. Remember that Ansible's strength lies in its idempotent nature - your playbooks should be safe to run multiple times. Use handlers for efficient service management, leverage conditionals and loops for dynamic execution, and always secure sensitive data with Ansible Vault.

Practice with different modules, experiment with deployment strategies, and don't forget to implement proper error handling. With these fundamentals in place, you'll be able to automate complex infrastructure tasks and maintain consistent, reliable deployments across your environment.