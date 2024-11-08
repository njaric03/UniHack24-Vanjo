from typing import Any, Dict, Optional, List
import networkx as nx
import pandas as pd
from numpy import nan
import matplotlib.pyplot as plt

class UserGraph:
    def __init__(self) -> None:
        self.graph: nx.MultiDiGraph = nx.MultiDiGraph()
        self.cycles: List[List] = []
        self.nodes_in_cycle : List = []

    def add_user(self, user_id: Any, attributes: Dict) -> None:
        """
        Add a user node to the graph with optional attributes and automatically create edges
        if teaching and learning subjects match between users.

        Parameters:
            user_id (Any): Unique identifier for the user.
            attributes (Dict): Dictionary of user attributes, including 'teaching_subject',
                               'learning_subject', and 'rating_avg'.
        """
        # Add the user as a node in the graph, including all attributes in the `attributes` dictionary
        if user_id in self.graph.nodes.keys():
            return

        self.graph.add_node(user_id, **attributes)

        # If the user has a non-NaN 'teaching_subject', create edges for matching 'learning_subject' nodes
        if attributes['teaching_subject'] is not nan:
            for x, data in self.graph.nodes(data=True):
                # Check if any node has a 'learning_subject' matching this user's 'teaching_subject'
                if data.get('learning_subject') == attributes['teaching_subject']:
                    edge_attrs = {
                        'subject': attributes['teaching_subject'],
                        'rating_avg_teacher': attributes['rating_avg_teacher']
                    }
                    # Add a directed edge from this user (teacher) to the matching student node
                    self.graph.add_edge(user_id, x, **edge_attrs)

        # If the user has a non-NaN 'learning_subject', create edges for matching 'teaching_subject' nodes
        if attributes['learning_subject'] is not nan:
            for x, data in self.graph.nodes(data=True):
                # Check if any node has a 'teaching_subject' matching this user's 'learning_subject'
                if data.get('teaching_subject') == attributes['learning_subject']:
                    edge_attrs = {
                        'subject': data['teaching_subject'],
                        'rating_avg_teacher': data['rating_avg_teacher']
                    }
                    # Add a directed edge from the matching teacher node to this user (student)
                    self.graph.add_edge(x, user_id, **edge_attrs)

        # Update the cycles and nodes involved in cycles after adding the new user and edges
        self._update()

    def remove_user(self, user_id: Any) -> None:
        if self.graph.has_node(user_id):
            self.graph.remove_node(user_id)
            self._update()

    def find_best_cycle(self, user_id: Any) -> Optional[list]:
        """
        Find the best cycle (shortest or most favorable path) starting and ending at a given user.

        Parameters:
            user_id (Any): Unique identifier for the user.
            weight (Optional[str]): Edge attribute to use as weight for cycle calculation.

        Returns:
            Optional[list]: List of nodes forming the best cycle for the user, or None if no cycle is found.
        """
        if user_id not in self.graph:
            return None

        lst = []
        for i, x in enumerate(self.cycles):
            if user_id in x:
                sum_of_weights = sum([self.graph.nodes(data=True)[y].get('rating_avg_teacher') for y in x])
                lst.append((x, sum_of_weights))
        lst = sorted(lst, key= lambda x: (len(x[0]), -x[1]))

        if len(lst) == 0:
            return None

        return lst[0][0]

    def _update(self):
        self.cycles = list(nx.simple_cycles(self.graph, length_bound=5))
        self.nodes_in_cycle = set([x for xs in self.cycles for x in xs])

    def build_from_dataframe(self,
                             users_df: pd.DataFrame,
                             edges_df: pd.DataFrame) -> None:
        """
        Build the graph from DataFrames for users and edges.

        Parameters:
            users_df (pd.DataFrame): DataFrame containing user information.
            edges_df (pd.DataFrame): DataFrame containing edges information.
        """

        source_col = 'user_id_teacher'
        target_col = 'user_id_student'
        edge_cols = ['subject', 'rating_avg_teacher']

        G = nx.from_pandas_edgelist(edges_df, source=source_col, target=target_col, edge_attr=edge_cols,
                                    create_using=nx.MultiDiGraph)
        nx.set_node_attributes(G, users_df.set_index('user_id')['rating_avg'].to_dict(), 'rating_avg_teacher')
        nx.set_node_attributes(G, users_df.set_index('user_id')['teaching_subject'].to_dict(), 'teaching_subject')
        nx.set_node_attributes(G, users_df.set_index('user_id')['learning_subject'].to_dict(), 'learning_subject')

        self.graph = G


    def draw_cycle(self, user_id : int):
        plt.figure(figsize=(10, 5))

        cycle_nodes = self.find_best_cycle(user_id)

        if cycle_nodes is None:
            return

        sG = self.graph.subgraph(cycle_nodes)
        pos = nx.planar_layout(sG)
        nx.draw(sG, with_labels=True, pos=pos)
        edge_labels = {(u, v): f"Subject: {d['subject']}, Rating: {d['rating_avg_teacher']}"
                       for u, v, d in sG.edges(data=True)}

        nx.draw_networkx_edge_labels(sG, pos=pos, edge_labels=edge_labels, connectionstyle='arc3,rad=0.1')
        plt.show()

