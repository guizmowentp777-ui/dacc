$code = [System.IO.File]::ReadAllText('c:\Users\guizm\Documents\hamstere\js\game.js')

# Simple tokenizer in C# to parse JS and find syntax errors / unclosed braces
$source = @"
using System;
using System.Collections.Generic;

public class JsChecker {
    public static void Check(string text) {
        int depth = 0;
        int line = 1;
        int col = 1;
        bool inLineComment = false;
        bool inBlockComment = false;
        bool inString = false;
        char stringChar = ' ';
        
        Stack<string> stack = new Stack<string>();

        for (int i = 0; i < text.Length; i++) {
            char c = text[i];
            char next = (i + 1 < text.Length) ? text[i + 1] : '\0';

            if (c == '\n') {
                line++;
                col = 1;
                inLineComment = false;
                continue;
            }
            col++;

            if (inLineComment) continue;
            if (inBlockComment) {
                if (c == '*' && next == '/') {
                    inBlockComment = false;
                    i++;
                }
                continue;
            }

            if (inString) {
                if (c == '\\') {
                    i++; // skip escaped char
                    continue;
                }
                if (c == stringChar) {
                    inString = false;
                }
                continue;
            }

            // Not in comment or string
            if (c == '/' && next == '/') {
                inLineComment = true;
                i++;
                continue;
            }
            if (c == '/' && next == '*') {
                inBlockComment = true;
                i++;
                continue;
            }

            if (c == '\'' || c == '"' || c == '`') {
                inString = true;
                stringChar = c;
                continue;
            }

            if (c == '{') {
                depth++;
                stack.Push("line " + line + ":" + col);
            } else if (c == '}') {
                depth--;
                if (stack.Count > 0) stack.Pop();
                else Console.WriteLine("Unmatched } at line " + line + ":" + col);
            }
        }

        Console.WriteLine("Final depth: " + depth);
        if (stack.Count > 0) {
            Console.WriteLine("Unclosed { opened at:");
            foreach (var s in stack) {
                Console.WriteLine("  " + s);
            }
        }
    }
}
"@

Add-Type -TypeDefinition $source -Language CSharp
[JsChecker]::Check($code)
