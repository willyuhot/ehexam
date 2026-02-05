#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
验证part-I.txt的完整性和准确性
"""

import re
import os

# 原始试卷文件
files = [
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2021继教与网络学院学位考试模拟试题一及答案.txt',
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2021继教与网络学院学位考试模拟试题二及答案.txt',
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2021继教与网络学院学位考试模拟试题三及答案.txt',
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2024继教与网络学院学位考试模拟试题一及答案.txt',
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2024继教与网络学院学位考试模拟试题二及答案.txt',
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2024继教与网络学院学位考试模拟试题三及答案.txt'
]

# 从原始试卷提取题目和答案
original_questions = []

for file_path in files:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 提取Part I部分
        part1_match = re.search(r'\*\*Part I Use of Language.*?(?=\*\*Part II|\*\*Part III|$)', content, re.DOTALL)
        if part1_match:
            part1_content = part1_match.group(0)
            
            # 提取题目
            pattern = r'(\d+)\.\s*---(.*?)---\s*(.*?)\s*A[\)\.]\s*(.*?)\s*B[\)\.]\s*(.*?)\s*C[\)\.]\s*(.*?)\s*D[\)\.]\s*(.*?)\s*(?:\*\*)?答案[：:]\s*([A-D])'
            questions = re.findall(pattern, part1_content, re.DOTALL)
            
            for q in questions:
                original_questions.append({
                    'num': q[0],
                    'dialogue1': q[1].strip(),
                    'dialogue2': q[2].strip(),
                    'A': q[3].strip(),
                    'B': q[4].strip(),
                    'C': q[5].strip(),
                    'D': q[6].strip(),
                    'answer': q[7].strip()
                })
    except Exception as e:
        print(f'Error reading {file_path}: {e}')

print(f'原始试卷题目总数: {len(original_questions)}')

# 读取part-I.txt
with open('/Users/yuhuahuan/code/EHExam/resources/part-I.txt', 'r', encoding='utf-8') as f:
    part1_content = f.read()

# 提取part-I.txt中的题目
pattern = r'第(\d+)题\n\n原题：--- (.*?)\n    --- (.*?)\n选项：\nA\) (.*?)\nB\) (.*?)\nC\) (.*?)\nD\) (.*?)\n你的答案：([A-D])\n核对结果：正确'
part1_questions = re.findall(pattern, part1_content, re.DOTALL)

print(f'part-I.txt题目总数: {len(part1_questions)}')

# 验证答案正确性
errors = []
for i, (num, d1, d2, a, b, c, d, ans) in enumerate(part1_questions):
    if i < len(original_questions):
        orig = original_questions[i]
        # 检查答案
        if ans != orig['answer']:
            errors.append({
                'question': int(num),
                'type': '答案错误',
                'part1_answer': ans,
                'original_answer': orig['answer'],
                'dialogue1': d1[:50]
            })
        # 检查对话内容
        if d1.strip() != orig['dialogue1'] or d2.strip() != orig['dialogue2']:
            errors.append({
                'question': int(num),
                'type': '对话内容不匹配',
                'part1_d1': d1[:50],
                'original_d1': orig['dialogue1'][:50]
            })

print(f'\n发现 {len(errors)} 个错误:')
for error in errors[:10]:  # 只显示前10个
    print(f"题目{error['question']}: {error['type']}")
    if 'part1_answer' in error:
        print(f"  part-I.txt答案: {error['part1_answer']}, 原始答案: {error['original_answer']}")

# 检查内容完整性
incomplete = []
for i, (num, d1, d2, a, b, c, d, ans) in enumerate(part1_questions):
    # 检查是否有译文
    question_block = re.search(rf'第{num}题.*?核心词', part1_content, re.DOTALL)
    if question_block:
        block = question_block.group(0)
        if '译文：---' in block and '译文：--- ---' not in block.replace('\n', ''):
            # 检查译文是否完整（不应该只是重复原题）
            if d1 in block.split('译文：')[1].split('【考点')[0]:
                incomplete.append({
                    'question': int(num),
                    'issue': '译文不完整或只是重复原题'
                })

print(f'\n发现 {len(incomplete)} 个内容不完整的问题:')
for item in incomplete[:5]:
    print(f"题目{item['question']}: {item['issue']}")

# 统计信息
print(f'\n=== 验证总结 ===')
print(f'原始试卷题目数: {len(original_questions)}')
print(f'part-I.txt题目数: {len(part1_questions)}')
print(f'答案错误数: {len([e for e in errors if e["type"] == "答案错误"])}')
print(f'内容不匹配数: {len([e for e in errors if e["type"] == "对话内容不匹配"])}')
print(f'内容不完整数: {len(incomplete)}')
