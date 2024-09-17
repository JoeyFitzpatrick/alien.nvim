import subprocess
import re

def parse_git_flags(command):
    usage_text = subprocess.run(['git', command, '--help'], capture_output=True, text=True).stdout
    # Find lines starting with 7 spaces followed by a dash and capture all flags on that line
    matches = re.findall(r'^ {7}(-\w(?:, --\w+[\w-]*)?)|(--\w+[\w-]*)', usage_text, re.MULTILINE)
    # Extract both single and multiple flag matches, filter out empty strings or None values and flatten the list
    flags = []
    for match in matches:
        for flag in match:
            if flag:
                flags.extend([f.strip() for f in flag.split(", ")])
    return list(set(flags))

def get_git_subcommands():
    help_text = subprocess.run(['git', '--help', '--all'], capture_output=True, text=True).stdout
    # Capture subcommands which usually appear at the start and preceded by 3 spaces
    subcommands = re.findall(r'^\s{3}(\w+)', help_text, re.MULTILINE)
    return list(set(subcommands))

def parse_all_git_flags(subcommands):
    all_flags = {}
    for subcommand in subcommands:
        try:
            all_flags[subcommand] = parse_git_flags(subcommand)
        except Exception as e:
            all_flags[subcommand] = f"Error: {str(e)}"
    return all_flags

def flags_to_lua_table(flags_dict):
    lua_table = "{\n"
    for subcommand, flags in flags_dict.items():
        lua_table += f'    "{subcommand}" = {{\n'
        for flag in flags:
            lua_table += f'        "{flag}",\n'
        lua_table += "    },\n"
    lua_table += "}\n"
    return lua_table

if __name__ == '__main__':
    all_flags = parse_all_git_flags(get_git_subcommands())
    lua_table = flags_to_lua_table(all_flags)
    print(lua_table)
