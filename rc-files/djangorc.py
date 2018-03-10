from django.db import connection
from IPython.terminal.prompts import Prompts, Token
import logging
logging.getLogger().setLevel(logging.WARNING)


class QueryCountPrompts(Prompts):
    def in_prompt_tokens(self, cli=None):
        return [
            (Token.Prompt, 'In['),
            (Token.PromptNum, str(self.shell.execution_count)),
            (Token.Prompt, '] Q['),
            (Token.PromptNum, str(len(connection.queries))),
            (Token.Prompt, ']: '),
        ]

def query_count_prompt():
    get_ipython().prompts = QueryCountPrompts(get_ipython())
