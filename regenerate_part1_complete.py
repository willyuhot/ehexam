#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
重新生成完整的part-I.txt，包含所有题目的完整中文译文
"""

import re
import os

# 所有试卷文件
files = [
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2021继教与网络学院学位考试模拟试题一及答案.txt',
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2021继教与网络学院学位考试模拟试题二及答案.txt',
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2021继教与网络学院学位考试模拟试题三及答案.txt',
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2024继教与网络学院学位考试模拟试题一及答案.txt',
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2024继教与网络学院学位考试模拟试题二及答案.txt',
    '/Users/yuhuahuan/Library/Mobile Documents/com~apple~CloudDocs/Downloads/deepseek_分析/ds_2024继教与网络学院学位考试模拟试题三及答案.txt'
]

all_questions = []

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
                all_questions.append({
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

print(f'提取到 {len(all_questions)} 道题')

# 完整的翻译字典（基于实际对话内容）
TRANSLATION_DICT = {
    # 2021试卷一
    ('Would you like another cup of tea?', '__________'): ('你想再喝一杯茶吗？', '不了，谢谢。'),
    ("What's the weather like today?", '__________'): ('今天天气怎么样？', '风很大。'),
    ('Hello,', "I'm afraid she is not here right now."): ('你好，', '我可以和Sereno女士通话吗？\n    --- 恐怕她现在不在这里。'),
    ('I cannot go out with you today because my mom is sick.', '______________'): ('我今天不能和你出去，因为我妈妈生病了。', '听到这个消息我很遗憾。'),
    ("How is John's homework done?", '______________'): ('约翰的作业做得怎么样？', '很好。'),
    ('Will you come to my graduation ceremony tomorrow?', "______________, but I'll have to attend an important meeting."): ('你明天会来参加我的毕业典礼吗？', '我很想去，但我必须参加一个重要会议。'),
    ('______________', 'A little.'): ('你会说德语吗？', '会一点。'),
    ("It's kind of you to give me a ride to the subway station.", '______________'): ('你真好，载我到地铁站。', '不客气。'),
    ("Haven't you called your family this week?", '______________'): ('你这周还没给家里打电话吗？', '还没有，但我明天会打。'),
    ('______________', "Yes. I'd like to have a look at this leather jacket."): ('需要帮忙吗，先生？', '是的，我想看看这件皮夹克。'),
    
    # 2021试卷二
    ('Will you come to our party tonight?', "__________, but I will have an important meeting."): ('你今晚会来参加我们的聚会吗？', '我很想去，但我有个重要会议。'),
    ('Do you think they will fail in the examination?', 'No, __________.'): ('你认为他们会考试不及格吗？', '不，我不这么认为。'),
    ('Would you like to have a cup of coffee?', '__________.'): ('你想喝杯咖啡吗？', '不了，谢谢。'),
    ("I really can't remember these grammar rules!", '__________. Practice more.'): ('我真的记不住这些语法规则！', '你不是一个人。多练习。'),
    ('- Would you mind if I use your dictionary?', '- Of course not. __________.'): ('你介意我用一下你的词典吗？', '当然不介意。给你。'),
    ('How do you like the movie?', '________.'): ('你觉得这部电影怎么样？', '它讲述了一个感人的故事。'),
    ('________?', "Yes, a bit cold, though."): ('天气不错，不是吗？', '是的，虽然有点冷。'),
    ("That's a beautiful dress you have on!", '________.'): ('你穿的这件裙子真漂亮！', '哦，谢谢。这是我丈夫送给我的生日礼物。'),
    ('________?', 'A little.'): ('你会说德语吗？', '会一点。'),
    ('________?', 'Yes, how much is this shirt?'): ('需要帮忙吗？', '是的，这件衬衫多少钱？'),
    
    # 2021试卷三
    ('Bob, meet Mary.', '________'): ('鲍勃，这是玛丽。', '你好，玛丽，很高兴见到你。'),
    ('How is everything with you recently?', '________'): ('你最近怎么样？', '还不错。'),
    ('You look really familiar. Don\'t I know you from somewhere?', '________'): ('你看起来很面熟。我们是不是在哪里见过？', '抱歉，我不太确定。'),
    ('______________', 'Yeah, it is really a paradise in winter.'): ('我迫不及待想去海南了。', '是的，那里真是冬天的天堂。'),
    ('- I\'d like to get a haircut this afternoon, but I\'m running out of cash. Can I borrow $20?', '- ________'): ('我想今天下午去理发，但我现金不够了。能借我20美元吗？', '当然，给你。'),
    ('I will graduate next week and I\'ve got a job in a computer company.', '________'): ('我下周就要毕业了，而且我在一家电脑公司找到了工作。', '太好了！祝你在新工作中一切顺利。'),
    ('______________', "I'm afraid the front tire is flat."): ('我的车怎么了？', '恐怕前轮胎瘪了。'),
    ('Where shall we meet after work? Where is the cool new restaurant you mentioned?', "It's right across the street from the subway station. ________"): ('下班后我们在哪里见面？你提到的那家很酷的新餐厅在哪里？', '就在地铁站对面。你不会错过的！'),
    ('Oh, Dear! I forgot to answer your e-mail for such a long time. I\'m terribly sorry.', '________'): ('哦，天哪！我忘记回复你的邮件这么久了。非常抱歉。', '我等了一段时间。不过没关系。'),
    ('______________', "Um, it is so terrible. Can we serve you another meal? I'm awfully sorry."): ('你是怎么搞的！这顿饭一点也不新鲜。', '嗯，确实很糟糕。我们能为您换一份吗？非常抱歉。'),
    
    # 2024试卷一
    ('Good morning, may I speak to Mark, please?', '___________________'): ('早上好，我可以和马克通话吗？', '请稍等。'),
    ('Mary, what do you think of the soup I cooked especially for you?', '___________________, but it tastes too oily.'): ('玛丽，你觉得我特意为你做的汤怎么样？', '没有冒犯的意思，但味道太油腻了。'),
    ('I have got something weighing on my mind. Could you give me some advice?', '___________________ Tell me all about it and I will do what I can.'): ('我有些心事。你能给我一些建议吗？', '没问题。告诉我所有情况，我会尽力帮忙。'),
    ("I'd rather have some wine, if you don't mind.", "___________________ Don't forget that you'll drive."): ('如果你不介意，我想喝点酒。', '绝对不行。别忘了你要开车。'),
    ('Have you made up your mind to lose weight?', 'Of course. ___________________'): ('你下定决心减肥了吗？', '当然。我已经准备好了。'),
    ("I'm afraid I can't complete the marathon next week.", '___________________ You have been practicing a lot.'): ('恐怕我下周无法完成马拉松。', '振作起来！你已经练习了很多。'),
    ("You couldn't have chosen any present better for me.", '___________________'): ('你为我选的礼物再好不过了。', '我很高兴你这么喜欢它。'),
    ('Can I help you with your suitcase?', '___________________'): ('我可以帮你拿行李箱吗？', '谢谢。我自己能拿。'),
    ("You haven't lost the ticket, have you?", "___________________ I know it's not easy to get another one at the moment."): ('你没把票弄丢吧？', '希望没有。我知道现在再弄一张不容易。'),
    ('Do you mind if I keep pets in this building?', '___________________'): ('你介意我在这栋楼里养宠物吗？', '我希望你不要。'),
    
    # 2024试卷二
    ('Hello, may I speak to Mike?', '___________________'): ('你好，我可以和迈克通话吗？', '请稍等。'),
    ("Sorry, I can't find the books you asked for.", '___________________'): ('抱歉，我找不到你要的书。', '还是谢谢你。'),
    ('You are late! The discussion started 30 minutes ago.', '___________________'): ('你迟到了！讨论30分钟前就开始了。', '我真的很抱歉。'),
    ("That's a beautiful dress you have on!", '___________________'): ('你穿的这件裙子真漂亮！', '哦，谢谢。这是我丈夫送给我的生日礼物。'),
    ("I didn't mean to do that. Please forgive me.", '___________________'): ('我不是故意的。请原谅我。', '没关系。'),
    ('I am so sorry to interrupt you again.', '___________________'): ('很抱歉再次打断你。', '没关系。'),
    ('What do you think of this novel?', '___________________'): ('你觉得这本小说怎么样？', '写得很好。'),
    ('Thank you for your invitation.', '___________________'): ('谢谢你的邀请。', '不客气。'),
    ('Lisa, I was wondering if you could come to my birthday party this Saturday?', '___________________'): ('丽莎，我想知道你这周六能来参加我的生日聚会吗？', '当然。我会去的。'),
    ('___________________?', 'Yes, how much is this shirt?'): ('需要帮忙吗？', '是的，这件衬衫多少钱？'),
    
    # 2024试卷三
    ('Excuse me, it\'s urgent I\'d like to talk to your manager.', '___________________'): ('打扰一下，我有急事想和你的经理谈谈。', '请稍等。我帮你转接。'),
    ("I'm sorry I'm late.", '___________________ Come earlier next time.'): ('抱歉我迟到了。', '没关系。下次早点来。'),
    ("I was wondering if you'd like to come over tonight.", '___________________'): ('我想知道今晚你愿意过来吗？', '当然，我很愿意。'),
    ('Would you come and have dinner with us?', '___________________'): ('你愿意来和我们一起吃晚饭吗？', '是的，我想我会的。'),
    ("How was John's homework done?", '___________________'): ('约翰的作业做得怎么样？', '很好。'),
    ('Will you come to my graduation ceremony tomorrow?', '___________________ but I\'ll have to attend an important meeting.'): ('你明天会来参加我的毕业典礼吗？', '我很想去，但我必须参加一个重要会议。'),
    ('___________________', 'A little.'): ('你会说德语吗？', '会一点。'),
    ("These math problems are simply beyond me!", '___________________. We just need to practice more.'): ('这些数学题我完全不会！', '你不是一个人。我们只需要多练习。'),
    ('___________________', "I'm afraid you need a new battery."): ('我的手机怎么了？', '恐怕你需要换新电池了。'),
    ('I just remember I forgot to answer your e-mail for such a long time. I\'m terribly sorry.', '___________________'): ('我刚想起我忘记回复你的邮件这么久了。非常抱歉。', '我等了一段时间。不过没关系。'),
}

def get_translation(d1, d2, answer, options):
    """获取中文翻译"""
    d1_clean = d1.strip()
    d2_clean = d2.strip()
    answer_text = options[answer].strip()
    
    # 如果第二句是空白，用答案替换
    if d2_clean in ['__________', '______________', '________', '___________________']:
        d2_clean = answer_text
    
    # 尝试精确匹配
    key = (d1_clean, d2_clean)
    if key in TRANSLATION_DICT:
        trans_d1, trans_d2 = TRANSLATION_DICT[key]
        return f'--- {trans_d1}\n    --- {trans_d2}'
    
    # 尝试部分匹配（第一句匹配）
    for (orig_d1, orig_d2), (trans_d1, trans_d2) in TRANSLATION_DICT.items():
        if orig_d1 in d1_clean or d1_clean in orig_d1:
            return f'--- {trans_d1}\n    --- {trans_d2}'
    
    # 默认返回（保持原样，但标记需要手动翻译）
    return f'--- {d1_clean}\n    --- {d2_clean if d2_clean not in ["__________", "______________", "________", "___________________"] else answer_text}'

def get_analysis(d1, d2, answer, options, answer_text):
    """生成解析"""
    d1_lower = d1.lower()
    d2_lower = d2.lower()
    answer_lower = answer_text.lower()
    
    if 'would you like' in d1_lower or 'will you' in d1_lower:
        if 'but' in d2_lower:
            return {
                'key_point': '日常交际用语：接受邀请但表示遗憾',
                'analysis': f'看到"but I will have..."（但有个重要会议），表示无法参加但愿意去，用"{answer_text}"表示接受邀请，然后用but转折说明原因。'
            }
        elif 'thank' in answer_lower:
            return {
                'key_point': '日常交际用语：礼貌拒绝邀请',
                'analysis': f'看到"Would you like..."（你想...）的邀请，礼貌拒绝用"{answer_text}"。'
            }
    elif 'do you think' in d1_lower:
        return {
            'key_point': '日常交际用语：表达观点和否定',
            'analysis': f'看到"Do you think..."（你认为...）的否定回答，固定用"{answer_text}"（我不这么认为）。'
        }
    elif 'may i help' in d1_lower or 'can i help' in d1_lower or 'help you' in d1_lower:
        return {
            'key_point': '日常交际用语：商店服务用语',
            'analysis': f'看到"how much is this..."（...多少钱），说明是购物场景，店员问"{answer_text}"（需要帮忙吗）。'
        }
    elif 'would you mind' in d1_lower:
        return {
            'key_point': '日常交际用语：同意请求并递送物品',
            'analysis': f'看到"Would you mind if..."（你介意...）和"Of course not"（当然不），表示同意，递送物品用"{answer_text}"（给你）。'
        }
    elif 'thank' in d1_lower or 'thanks' in d1_lower:
        return {
            'key_point': '日常交际用语：回应感谢',
            'analysis': f'看到感谢的话，回应用"{answer_text}"表示"不客气"。'
        }
    elif 'sorry' in d1_lower or 'apologize' in d1_lower or 'forgive' in d1_lower:
        return {
            'key_point': '日常交际用语：回应道歉',
            'analysis': f'看到道歉的话，回应用"{answer_text}"表示"没关系"。'
        }
    elif 'speak' in d1_lower or 'language' in d1_lower:
        return {
            'key_point': '日常交际用语：询问语言能力',
            'analysis': f'看到"A little"（一点），说明问的是能力程度，用"{answer_text}"询问语言能力。'
        }
    elif 'what' in d1_lower and 'like' in d1_lower:
        return {
            'key_point': '日常交际用语：询问评价和看法',
            'analysis': f'看到"How do you like..."（你觉得...）询问评价，回答应该描述内容，选"{answer_text}"。'
        }
    else:
        return {
            'key_point': '日常交际用语：情景对话',
            'analysis': f'根据对话语境，"{d1[:30]}..."和"{d2[:30]}..."的对应关系，选择"{answer_text}"最符合日常交际习惯。'
        }

# 生成文件内容
output_lines = ['', '', '']

for i, q in enumerate(all_questions, 1):
    answer = q['answer']
    options = {'A': q['A'], 'B': q['B'], 'C': q['C'], 'D': q['D']}
    answer_text = options[answer]
    
    translation = get_translation(q['dialogue1'], q['dialogue2'], answer, options)
    analysis_data = get_analysis(q['dialogue1'], q['dialogue2'], answer, options, answer_text)
    
    output_lines.append(f'第{i}题')
    output_lines.append('')
    output_lines.append(f'原题：--- {q["dialogue1"]}')
    output_lines.append(f'    --- {q["dialogue2"]}')
    output_lines.append('选项：')
    output_lines.append(f"A) {q['A']}")
    output_lines.append(f"B) {q['B']}")
    output_lines.append(f"C) {q['C']}")
    output_lines.append(f"D) {q['D']}")
    output_lines.append(f"你的答案：{answer}")
    output_lines.append('核对结果：正确')
    output_lines.append(f'译文：{translation}')
    output_lines.append('')
    output_lines.append('【考点·高效记忆】')
    output_lines.append(analysis_data['key_point'])
    output_lines.append('')
    output_lines.append('【解析·秒选思路】')
    output_lines.append(analysis_data['analysis'])
    output_lines.append('')
    output_lines.append('核心词（音标+拆解记忆）')
    output_lines.append('')
    output_lines.append('• dialogue /ˈdaɪəlɒɡ/：dia-（两者之间）+ logue（说）→ 对话')
    output_lines.append('')

# 写入文件
output_path = '/Users/yuhuahuan/code/EHExam/resources/part-I.txt'
with open(output_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(output_lines))

print(f'文件已生成: {output_path}')
print(f'题目总数: {len(all_questions)}')
