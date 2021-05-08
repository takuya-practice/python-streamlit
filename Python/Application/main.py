import streamlit as st 
import numpy as np 
import pandas as pd
from PIL import Image
import time

st.title('streamlist 超入門')

# 表を出力
# df = pd.DataFrame({
#     '1列目' : [1, 2, 3, 4],
#    '2列目' : [10, 20, 30, 40]
# })
# st.dataframe(df.style.highlight_max(axis=0), width=4000, height=4000)
# st.table(df.style.highlight_max(axis=0)) 


## マークダウンの挿入
"""
## 今回インポートしたもの

```python 
import streamlit as st 
import numpy as np 
import pandas as pd
from PIL import Image
import time
```
"""


# 折れ線グラフの挿入
# df = pd.DataFrame(
#     np.random.rand(20, 3),
#     columns=['a', 'b', 'c']
# )
# st.line_chart(df)


# マップの挿入
"""
## 新宿付近のマップを表示
"""

df = pd.DataFrame(
    np.random.rand(100, 2) / [50, 50] + [35.69, 139.70],
    columns=['lat', 'lon']
)
st.map(df)


# イメージの挿入
st.write('Display Image')
st.write('浜辺美波')

if st.checkbox('Show Image'):
    img = Image.open('YyfkGeb7.jpg')
    st.image(img, caption='takuya hirata', use_column_width=True)

# セレクトボックス
"""
## インタラクティブなウィジェット
"""

option = st.sidebar.selectbox(
    'あなたの好きな数字を選択してください。',
    list(range(1, 10))
)
st.write('あなたの好きな数字は', option, 'です。')

text = st.sidebar.text_input('あなたの趣味を教えてください。')
st.write('あなたの趣味は', text, 'です。')

condition = st.sidebar.slider(
    '今の調子は？',
    0, 100, 50
)
st.write('今の調子は', condition, 'です。')


left_column, right_column = st.beta_columns(2)
button = left_column.button('右カラムに文字を追加')
if button:
    right_column.write('ここは右カラム')

expander1 = st.beta_expander('問い合わせ1')
expander1.write('問い合わせ1')
expander2 = st.beta_expander('問い合わせ2')
expander2.write('問い合わせ2')
expander3 = st.beta_expander('問い合わせ3')
expander3.write('問い合わせ3')


"""
## プログレスバーの表示
"""
'Start!!'

latest_iteration = st.empty()
bar = st.progress(0)

for i in range(100):
    latest_iteration.text(f'Iteration {i + 1}')
    bar.progress(i + 1)
    time.sleep(0.1)

'Done!!!'