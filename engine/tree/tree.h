#include <stdlib.h>

#ifndef _TREE_H
#define _TREE_H

typedef struct {
  // The data contained at this node
  void *data;
  tree_t *tree;
  tree_node_t *parent;
  tree_node_t *prev_sibling;
  tree_node_t *next_sibling;
  tree_node_t *first_child;
} tree_node_t;

typedef struct {
  tree_node_t *root;
} tree_t;

typedef enum {
  DESCENDING,
  ASCENDING
} tree_direction;

tree_t *tree_new(void);
void tree_del(tree_t *);
void tree_walk(tree_node_t *n, (void)(*)(tree_node_t *, void *), void *);
tree_node_t *tree_get_last_child
    tree_append_child
    tree_create_node


#endif
