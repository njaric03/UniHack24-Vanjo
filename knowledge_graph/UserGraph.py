from typing import Any, Dict, Optional, List, Union
import networkx as nx
import pickle
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.offsetbox import OffsetImage, AnnotationBbox
import random
from PIL import Image, ImageOps, ImageDraw

AVATARS_PATH = '../resources/avatars/'
AVATAR_PATH_TEMPLATE = AVATARS_PATH + 'HEIF Image {}.jpeg'
NUM_AVATARS = len(os.listdir(AVATARS_PATH))


class UserGraph:
    def __init__(self) -> None:
        self.graph: nx.MultiDiGraph = nx.MultiDiGraph()
        self.cycles: List[List] = []
        self.nodes_in_cycle : List = []
        self.images = self._load_images()

    def _load_images(self) -> List:

        def load_and_process_image(image_path):
            img = Image.open(image_path).convert("RGBA")
            size = min(img.size)
            mask = Image.new("L", img.size, 0)
            draw = ImageDraw.Draw(mask)
            draw.ellipse((0, 0, size, size), fill=255)
            mask = mask.resize(img.size)
            circular_img = ImageOps.fit(img, (size, size), centering=(0.5, 0.5))
            circular_img.putalpha(mask)
            return circular_img

        return [load_and_process_image(AVATAR_PATH_TEMPLATE.format(i)) for i in range(1, NUM_AVATARS+1)]

    def add_user(self, user_id: Any, attributes: Dict) -> None:
        if user_id in self.graph.nodes.keys():
            return

        self.graph.add_node(user_id, **attributes)

        if attributes['teaching_subject'] is not np.nan:
            for x, data in self.graph.nodes(data=True):
                if data.get('learning_subject') == attributes['teaching_subject']:
                    edge_attrs = {
                        'subject': attributes['teaching_subject'],
                        'rating_avg_teacher': attributes['rating_avg_teacher']
                    }
                    self.graph.add_edge(user_id, x, **edge_attrs)

        if attributes['learning_subject'] is not np.nan:
            for x, data in self.graph.nodes(data=True):
                if data.get('teaching_subject') == attributes['learning_subject']:
                    edge_attrs = {
                        'subject': data['teaching_subject'],
                        'rating_avg_teacher': data['rating_avg_teacher']
                    }
                    self.graph.add_edge(x, user_id, **edge_attrs)

        self._update()

    def remove_user(self, user_id: Any) -> None:
        if self.graph.has_node(user_id):
            self.graph.remove_node(user_id)
            self._update()

    def find_best_cycle(self, user_id: Any) -> Optional[list]:
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

        source_col = 'user_id_teacher'
        target_col = 'user_id_student'
        edge_cols = ['subject', 'rating_avg_teacher']

        G = nx.from_pandas_edgelist(edges_df, source=source_col, target=target_col, edge_attr=edge_cols,
                                    create_using=nx.MultiDiGraph)
        nx.set_node_attributes(G, users_df.set_index('user_id')['rating_avg'].to_dict(), 'rating_avg_teacher')
        nx.set_node_attributes(G, users_df.set_index('user_id')['teaching_subject'].to_dict(), 'teaching_subject')
        nx.set_node_attributes(G, users_df.set_index('user_id')['learning_subject'].to_dict(), 'learning_subject')

        self.graph = G


    def draw_cycle(self, user_id : int, connection_style = 'arc3,rad=0.1'):
        
        
        best_cycle = self.find_best_cycle(user_id)

        if best_cycle is None:
            return

        G = nx.subgraph(self.graph, best_cycle)

        pos = nx.arf_layout(G, pos = nx.planar_layout(G))

        teaching_subjects = set(nx.get_node_attributes(G, 'teaching_subject').values())
        color_map = {subject: f'#{random.randint(0, 0xFFFFFF):06x}' for subject in teaching_subjects}

        plt.figure(figsize=(10, 7))

        edge_labels = {(u, v): f"{d['subject']} ({d['rating_avg_teacher']})"
                       for u, v, d in G.edges(data=True)}

        nx.draw(
            G, pos, node_size=0, edge_color='black',
            arrows=True, arrowsize=1, connectionstyle=connection_style,
        )

        for edge in G.edges():
            source, target = edge

            arrowstyle = '-|>'  # Define arrow shape
            arrowsize = 30  # Define arrow length
            start_subject = G.nodes[source]['teaching_subject']
            edge_color = color_map[start_subject]  # Use the start node's teaching subject for color

            nx.draw_networkx_edges(
                G, pos,
                edgelist=[(source, target)],
                arrowstyle=arrowstyle,
                arrowsize=arrowsize,
                edge_color=edge_color,
                min_target_margin=20,
                connectionstyle=connection_style
            )
            nx.draw_networkx_edge_labels(
                G, pos,
                edge_labels=edge_labels,
                connectionstyle=connection_style,
                font_family='monospace'
            )
            
        ax = plt.gca()
        for node, (x, y) in pos.items():
            print(node, node % NUM_AVATARS)
            img = np.array(self.images[node % NUM_AVATARS])

            imagebox = OffsetImage(img, zoom=0.04)
            ab = AnnotationBbox(imagebox, (x, y), frameon=False)
            ax.add_artist(ab)

        plt.savefig(f'{user_id}_best_cycle.png', transparent=True)
        plt.axis('off')
        plt.show()

    def save_to_file(self, file_path: Union[str, os.PathLike]) -> None:
        with open(file_path, 'wb') as f:
            pickle.dump(self, f)

    @classmethod
    def load_from_file(cls, file_path: Union[str, os.PathLike]) -> 'UserGraph':
        with open(file_path, 'rb') as f:
            return pickle.load(f)