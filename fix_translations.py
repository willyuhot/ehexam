#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
为part-I.txt补全所有题目的中文译文
"""

import re

# 读取part-I.txt
with open('/Users/yuhuahuan/code/EHExam/resources/part-I.txt', 'r', encoding='utf-8') as f:
    content = f.read()

# 翻译字典（基于对话内容）
translations = {
    # 第1题已完整
    # 第2题已完整
    
    # 第3题
    ('Hello,', 'I\'m afraid she is not here right now.'): '--- 你好，我可以和Sereno女士通话吗？\n    --- 恐怕她现在不在这里。',
    
    # 第4题
    ('I cannot go out with you today because my mom is sick.', '______________'): '--- 我今天不能和你出去，因为我妈妈生病了。\n    --- 听到这个消息我很遗憾。',
    
    # 第5题
    ('How is John\'s homework done?', '______________'): '--- 约翰的作业做得怎么样？\n    --- 很好。',
    
    # 第6题
    ('Will you come to my graduation ceremony tomorrow?', '______________, but I\'ll have to attend an important meeting.'): '--- 你明天会来参加我的毕业典礼吗？\n    --- 我很想去，但我必须参加一个重要会议。',
    
    # 第7题
    ('______________', 'A little.'): '--- 你会说德语吗？\n    --- 会一点。',
    
    # 第8题
    ('It\'s kind of you to give me a ride to the subway station.', '______________'): '--- 你真好，载我到地铁站。\n    --- 不客气。',
    
    # 第9题
    ('Haven\'t you called your family this week?', '______________'): '--- 你这周还没给家里打电话吗？\n    --- 还没有，但我明天会打。',
    
    # 第10题
    ('______________', 'Yes. I\'d like to have a look at this leather jacket.'): '--- 需要帮忙吗，先生？\n    --- 是的，我想看看这件皮夹克。',
    
    # 第11题
    ('Bob, meet Mary.', '________'): '--- 鲍勃，这是玛丽。\n    --- 你好，玛丽，很高兴见到你。',
    
    # 第12题
    ('How is everything with you recently?', '________'): '--- 你最近怎么样？\n    --- 还不错。',
    
    # 第13题
    ('You look really familiar. Don\'t I know you from somewhere?', '________'): '--- 你看起来很面熟。我们是不是在哪里见过？\n    --- 抱歉，我不太确定。',
    
    # 第14题
    ('______________', 'Yeah, it is really a paradise in winter.'): '--- 我迫不及待想去海南了。\n    --- 是的，那里真是冬天的天堂。',
    
    # 第15题
    ('- I\'d like to get a haircut this afternoon, but I\'m running out of cash. Can I borrow $20?', '- ________'): '--- 我想今天下午去理发，但我现金不够了。能借我20美元吗？\n    --- 当然，给你。',
    
    # 第16题
    ('I will graduate next week and I\'ve got a job in a computer company.', '________'): '--- 我下周就要毕业了，而且我在一家电脑公司找到了工作。\n    --- 太好了！祝你在新工作中一切顺利。',
    
    # 第17题
    ('______________', 'I\'m afraid the front tire is flat.'): '--- 我的车怎么了？\n    --- 恐怕前轮胎瘪了。',
    
    # 第18题
    ('Where shall we meet after work? Where is the cool new restaurant you mentioned?', 'It\'s right across the street from the subway station. ________'): '--- 下班后我们在哪里见面？你提到的那家很酷的新餐厅在哪里？\n    --- 就在地铁站对面。你不会错过的！',
    
    # 第19题
    ('Oh, Dear! I forgot to answer your e-mail for such a long time. I\'m terribly sorry.', '________'): '--- 哦，天哪！我忘记回复你的邮件这么久了。非常抱歉。\n    --- 我等了一段时间。不过没关系。',
    
    # 第20题
    ('______________', 'Um, it is so terrible. Can we serve you another meal? I\'m awfully sorry.'): '--- 你是怎么搞的！这顿饭一点也不新鲜。\n    --- 嗯，确实很糟糕。我们能为您换一份吗？非常抱歉。',
}

def translate_dialogue(d1, d2, answer_text):
    """生成中文译文"""
    d1_clean = d1.strip()
    d2_clean = d2.strip()
    
    # 如果第二句是空白或下划线，用答案替换
    if d2_clean in ['__________', '______________', '________']:
        d2_clean = answer_text
    
    # 尝试从字典获取翻译
    key = (d1_clean, d2_clean)
    if key in translations:
        return translations[key]
    
    # 如果没有，尝试部分匹配
    for (orig_d1, orig_d2), trans in translations.items():
        if orig_d1 in d1_clean or d1_clean in orig_d1:
            if orig_d2 in d2_clean or d2_clean in orig_d2 or d2_clean in ['__________', '______________', '________']:
                return trans
    
    # 默认翻译（简单处理）
    trans_d1 = d1_clean
    trans_d2 = d2_clean if d2_clean not in ['__________', '______________', '________'] else answer_text
    
    # 简单的英文到中文映射
    simple_trans = {
        'Would you like': '你想',
        'another cup of tea': '再喝一杯茶吗',
        'No, thanks': '不了，谢谢',
        'What\'s the weather like': '天气怎么样',
        'It\'s rather windy': '风很大',
        'may I speak to': '我可以和...通话吗',
        'I\'m afraid': '恐怕',
        'I cannot go out': '我不能出去',
        'because my mom is sick': '因为我妈妈生病了',
        'I\'m sorry to hear that': '听到这个消息我很遗憾',
        'How is': '...怎么样',
        'homework done': '作业做得',
        'Pretty well': '很好',
        'Will you come': '你会来',
        'graduation ceremony': '毕业典礼',
        'I\'d love to': '我很想去',
        'but I\'ll have to attend': '但我必须参加',
        'an important meeting': '一个重要会议',
        'Do you speak German': '你会说德语吗',
        'A little': '会一点',
        'It\'s kind of you': '你真好',
        'give me a ride': '载我一程',
        'It was my pleasure': '不客气',
        'Haven\'t you called': '你还没打电话',
        'Not yet, but I\'m calling tomorrow': '还没有，但我明天会打',
        'May I help you': '需要帮忙吗',
        'I\'d like to have a look': '我想看看',
        'leather jacket': '皮夹克',
    }
    
    # 尝试简单翻译
    for eng, chn in simple_trans.items():
        if eng in trans_d1:
            trans_d1 = trans_d1.replace(eng, chn)
        if eng in trans_d2:
            trans_d2 = trans_d2.replace(eng, chn)
    
    return f'--- {trans_d1}\n    --- {trans_d2}'

# 提取所有题目并更新译文
pattern = r'(第(\d+)题\n\n原题：--- (.*?)\n    --- (.*?)\n选项：\nA\) (.*?)\nB\) (.*?)\nC\) (.*?)\nD\) (.*?)\n你的答案：([A-D])\n核对结果：正确\n译文：)(.*?)(\n\n【考点)'

def replace_translation(match):
    full_match = match.group(0)
    num = match.group(2)
    d1 = match.group(3)
    d2 = match.group(4)
    answer = match.group(9)
    answer_text = match.group(int(ord(answer) - ord('A') + 5))  # 获取对应选项
    
    before_trans = match.group(1)
    old_trans = match.group(11)
    after_trans = match.group(12)
    
    # 检查是否需要翻译
    if '---' in old_trans and not any('\u4e00' <= char <= '\u9fff' for char in old_trans):
        new_trans = translate_dialogue(d1, d2, answer_text)
        return before_trans + new_trans + after_trans
    else:
        return full_match

# 替换所有需要翻译的部分
new_content = re.sub(pattern, replace_translation, content, flags=re.DOTALL)

# 写入文件
with open('/Users/yuhuahuan/code/EHExam/resources/part-I.txt', 'w', encoding='utf-8') as f:
    f.write(new_content)

print('译文补全完成！')
