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
from io import BytesIO

AVATARS_PATH = '../resources/avatars/'
AVATAR_PATH_TEMPLATE = AVATARS_PATH + 'HEIF Image {}.jpeg'
NUM_AVATARS = len(os.listdir(AVATARS_PATH))


class UserGraph:
    def __init__(self) -> None:
        self.graph: nx.MultiDiGraph = nx.MultiDiGraph()
        self.cycles: List[List] = []
        self.pending_cycles: List[List] = []
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
        nx.set_node_attributes(G, users_df.set_index('user_id')['avatar_id'].to_dict(), 'avatar_id')

        self.graph = G
        self.cycles = list(nx.simple_cycles(G, length_bound=5))
        self.pending_cycles = []

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

        new_cycles = list(nx.simple_cycles(self.graph, length_bound=5))
        self.cycles = self.cycles + [cycle for cycle in new_cycles if user_id in cycle]
        self.save_to_file('../resources/userbase/userbase_graph.pkl')


    def remove_user(self, user_id: Any) -> None:
        if self.graph.has_node(user_id):
            self.graph.remove_node(user_id)
            self.cycles = [cycle for cycle in self.cycles if user_id not in cycle]
            self.save_to_file('../resources/userbase/userbase_graph.pkl')

    def find_best_cycle(self, user_id: Any) -> Optional[list]:
        if user_id not in self.graph:
            return None

        lst = []
        for i, x in enumerate(self.cycles):
            if user_id in x:
                sum_of_weights = 0
                for node in x:
                    weight = self.graph.nodes(data=True)[node].get('rating_avg_teacher')
                    sum_of_weights += weight if weight is not None else 0
                lst.append((x, sum_of_weights))
        lst = sorted(lst, key= lambda x: (len(x[0]), -x[1]))

        if len(lst) == 0:
            return None

        self.pending_cycles.append(lst[0][0])
        self.cycles.remove(lst[0][0])

        return lst[0][0]

    def change_cycle_status(self, cycle, success = True):
        if not success and cycle in self.pending_cycles:
            self.pending_cycles.remove(cycle)

    def draw_cycle(self, user_id: int, connection_style='arc3,rad=0.1'):
        best_cycle = self.find_best_cycle(user_id)

        # Return None if no cycle is found
        if best_cycle is None:
            return None, None

        # Create the subgraph for the cycle
        G = nx.subgraph(self.graph, best_cycle)

        # Position the nodes using a layout
        pos = nx.spring_layout(G, pos=nx.planar_layout(G))

        # Prepare colors for each teaching subject
        teaching_subjects = set(nx.get_node_attributes(G, 'teaching_subject').values())
        avatar_ids = {x: data['avatar_id'] - 1 for x, data in G.nodes(data=True)}
        color_map = {subject: f'#{random.randint(0, 0xFFFFFF):06x}' for subject in teaching_subjects}

        # Create the plot
        plt.figure(figsize=(17, 17))
        edge_labels = {(u, v): f"{d['subject']} ({d['rating_avg_teacher']})"
                       for u, v, d in G.edges(data=True)}

        nx.draw(
            G, pos, node_size=0, edge_color='black',
            arrows=True, arrowsize=1, connectionstyle=connection_style,
        )

        for edge in G.edges():
            source, target = edge
            arrowstyle = '-|>'  # Arrow shape
            arrowsize = 30  # Arrow length
            start_subject = G.nodes[source]['teaching_subject']
            edge_color = color_map[start_subject]  # Color based on start node's teaching subject

            nx.draw_networkx_edges(
                G, pos,
                edgelist=[(source, target)],
                arrowstyle=arrowstyle,
                arrowsize=arrowsize,
                edge_color=edge_color,
                min_target_margin=100,
                connectionstyle=connection_style
            )
            nx.draw_networkx_edge_labels(
                G, pos,
                edge_labels=edge_labels,
                connectionstyle=connection_style,
                font_family='monospace',
                font_size=40
            )

        # Add avatar images at each node position
        ax = plt.gca()
        for node, (x, y) in pos.items():
            img = np.array(self.images[avatar_ids[node]])
            imagebox = OffsetImage(img, zoom=0.2)
            ab = AnnotationBbox(imagebox, (x, y), frameon=False)
            ax.add_artist(ab)

        # Save image to a BytesIO object
        image_io = BytesIO()
        plt.savefig(image_io, format='PNG', transparent=True)
        image_io.seek(0)  # Reset pointer to start of stream

        plt.axis('off')
        plt.show()
        plt.close()

        # Return the cycle nodes and the image as bytes
        return best_cycle, image_io.getvalue()

    def save_to_file(self, file_path: Union[str, os.PathLike]) -> None:
        with open(file_path, 'wb') as f:
            pickle.dump(self, f)

    @classmethod
    def load_from_file(cls, file_path: Union[str, os.PathLike]) -> 'UserGraph':
        with open(file_path, 'rb') as f:
            return pickle.load(f)