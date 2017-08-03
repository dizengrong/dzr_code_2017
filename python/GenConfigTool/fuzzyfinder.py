# -*- coding: utf-8 -*- 
import re

# 贪婪模糊匹配
# collection为一个字典，其key为要进行比较匹配的字符串，
def fuzzyfinder(user_input, collection):
	suggestions = []
	pattern = '.*?'.join(user_input)    # Converts 'djm' to 'd.*?j.*?m'
	regex = re.compile(pattern)         # Compiles a regex.
	for item in collection:
		match = regex.search(item)      # Checks if the current item matches the regex.
		temp = {item:collection[item]}
		if match:
			suggestions.append((len(match.group()), match.start(), temp))
	if len(suggestions) == 0:
		return {}
	else:
		ret = {}
		for _, _, x in sorted(suggestions):
			ret.update(x)
		# ret = [x for _, _, x in sorted(suggestions)]
		return ret
