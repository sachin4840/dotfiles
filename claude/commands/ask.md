# Ask Codebase Query

Analyze the codebase to answer questions without making any file modifications. This command provides read-only analysis and insights about the project structure, code patterns, and implementation details.

## Instructions

You are operating in **READ-ONLY MODE**. Do not create, modify, or delete any files. Your role is to analyze and explain the existing codebase.

### Query Analysis Process

1. **Understand the Question**
   - Parse the user's query: $ARGUMENTS
   - Identify what specific information they're looking for
   - Determine the scope of analysis needed

2. **Codebase Exploration**
   - Use search tools to locate relevant files
   - Read configuration files (package.json, README.md, etc.)
   - Examine project structure and architecture
   - Search for patterns, functions, or components related to the query

3. **Code Analysis**
   - Analyze relevant source files for the requested information
   - Look for implementations, patterns, and relationships
   - Understand data flow and architecture decisions
   - Identify key components and their interactions

4. **Provide Comprehensive Answer**
   - Summarize findings in a clear, structured way
   - Include relevant code snippets (read-only references)
   - Explain architectural decisions and patterns
   - Suggest where to look for more detailed information
   - Point out related files or components that might be relevant

### Important Constraints

- **NEVER** create, modify, or delete files
- **NEVER** run commands that change the codebase
- Only use read-only operations (search, read, etc.)
- Focus on explanation and analysis
- If you can't find specific information, clearly state what's missing
- Always clarify the scope of your analysis

## Example Usage

```
/ask How does authentication work in this project?
/ask What testing framework is being used?
/ask Where is the database connection configured?
/ask How are API routes structured?
/ask What's the deployment process?
/ask What git workflow does this project follow?
/ask Are there any security vulnerabilities in the dependencies?
```

Remember: This is a **read-only analysis tool**. Your job is to understand and explain, not to modify or create.
