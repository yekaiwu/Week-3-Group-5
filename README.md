# What you get:
- Arduino Nano 33 Sense Rev2 board
- main.py file
- Arduino Studio project which acts as a firmware

# What you need:
- Laptop
- Arduino Nano Sense Rev2
- Arduino IDE
- Python editor (e.g., Visual Studio)
- Python v13.x
- Claude Desktop application

# Installing instructions

- Claude
    - Install Claude Desktop, unless you have one already. You do not need paid subscript - free version is enough for this assignment!

- Python
    1. Check which Python version you have. The exceircise require Python 3.14 minumum. Use uv or some other for making sure you have at least this version Python
    2. Install the dependencies (fastmcp, pyserial). (Depends how you run you python, e.g., uv pip install fastmcp pyserial)

- Arduino:
    1. Install Arduino IDE
    2. Connect Arduino to your computer
    3. You likely need to install some dependencies for your Arduino Studio: 
        - Arduino_HS300x 
        - Arduino_LPS22HB
        - Arduino_APDS9960
        - Arduino_BMI270_BMM150
        - Arduino_JSON

- Configure:
    - Check the Arduino port from the Aruino IDE and set in in the main.py file (PORT='/dev/cu.usbmodem11201')


- Open your code editor (e.g., Visual Studio Code) and start coding!


# Assignment instructions

**Your task is to**:

1. Practice: Inspect main.py and implement blue LED control tool for MCP, and test via Claude

2. Use your creativity:
    - Design & implement your own tool
    - Design outputs for the system
    - Implement “a program” on Claude how to use your tool

3. Document & present:
    - Explain what your tool does and how it can be used with Claude


Things to consider:
- How should the return values and message be when you are communicating with LM?


Edit your Claude's config file and add your MCP server: claude_desktop_config.json. You can find this via Claude's settings -> Developer -> Edit Config

The config depends on how you run your python. Here is an example with uv:

```
{
  "mcpServers": {
    "DevAIoT": {
      "command": "uv",
      "args": [
        "--directory",
        "/Users/nkm/temp/DevAIoT_2026/week3/Server",
        "run",
        "main.py"
      ]
    }
  }
}
```

## Logs

You can observer the logs from your Claude's log files (filename: mcp-server-DevAIoT.log)

/Users/nkm/Library/Logs/Claude




## Possible issues and solutions:

- If you get serial port issue: 1) check (from Arduino Studio) that your port is correct, 2) make sure you use pyserial - not plain serial