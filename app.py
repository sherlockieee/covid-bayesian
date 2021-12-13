import hedgehog as hh
import pandas as pd
import streamlit as st


bn = hh.BayesNet(
    ("Gabriel", "Ha"), ("Ha", "Esther"), ("Gabriel", "Anais"), ("Ha", "Anais")
)

# P(Gabriel gets COVID)
bn.P["Gabriel"] = pd.Series({False: 0.5, True: 0.5})

# P(Ha gets COVID | Gabriel gets COVID)
bn.P["Ha"] = pd.Series(
    {(True, True): 0.7, (True, False): 0.3, (False, True): 0.4, (False, False): 0.6}
)

# P(Anais gets COVID | Gabriel gets COVID, Ha gets COVID)
bn.P["Anais"] = pd.Series(
    {
        (True, True, True): 0.92,
        (True, True, False): 0.08,
        (True, False, True): 0.3,
        (True, False, False): 0.7,
        (False, True, True): 0.44,
        (False, True, False): 0.56,
        (False, False, True): 0.1,
        (False, False, False): 0.9,
    }
)

# P(Esther gets COVID | Ha gets COVID)
bn.P["Esther"] = pd.Series(
    {(True, True): 0.94, (True, False): 0.06, (False, True): 0.43, (False, False): 0.56}
)

bn.prepare()


###DISPLAYING USING STREAMLIT
dot = bn.graphviz()
path = dot.render("COVID", directory="figures", format="svg", cleanup=True)


st.graphviz_chart(dot)

"""Probability that Anais has COVID given that Gabriel has COVID"""
anais = bn.query("Anais", event={"Gabriel": True})


st.dataframe(anais)
