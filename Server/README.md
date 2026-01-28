# What you get:
- Arduino Nano 33 Sense Rev2 board
- main.py file
- Arduino Studio project which acts as a firmware


# Installing instructions

- Check which Python version you have. The exceircise require Python 3.14 minumum. Use uv or some other for making sure you have at least this version Python
- Install the dependencies. You can use for example uv

- Install Arduino IDE
- Connect Arduino to your computer
- You likely need to install some dependencies for your Arduino Studio: Arduino_HS300x, Arduino_LPS22HB, Arduino_APDS9960, Arduino_BMI270_BMM150, and Arduino_JSON

- Check the Arduino port from the Aruino IDE and set in in the main.py file (PORT='/dev/cu.usbmodem11201')

- Install dependencies: (fastmcp, pyserial). Depending how you run you python, e.g., uv pip install fastmcp pyserial
- Open you code editor (e.g., Visual Studio Code) and start coding!


# Assignment instructions

**Your task is to**:

1. Implement X and its counter part in main.py
2. 


Things to consider:
- How should the return values and message be when you are communicating with LM?


Edit your Claude's config file and add your MCP server: claude_desktop_config.json. You can find this via Claude's settings -> Developer -> Edit Config

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


## Logs

You can observer the logs from your Claude's log files (filename: mcp-server-DevAIoT.log)

/Users/nkm/Library/Logs/Claude




## Possible issues and solutions:

- If you get serial port issue: 1) check (from Arduino Studio) that your port is correct, 2) make sure you use pyserial - not plain serial