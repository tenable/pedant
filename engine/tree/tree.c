#include "tree.h"
#include <stdbool.h>
#include <stdlib.h>

tree_t *tree_new(void)
{
  tree_t *t = malloc(sizeof(tree_t));
  if (t == NULL)
    return NULL;

  t->num_elems = 0;
  t->root = NULL;

  return t;
}

void tree_del(tree_t *t)
{
  assert(t != NULL);
  // walk the tree bottom-up and free each node
}

void tree_recursive_free(tree_node_t *n)
{
  assert(n != NULL);

  

  // if (n->first_child == NULL)
  // base case
  free(n);
}

void tree_walk(tree_node_t *n, (void)(*f)(void *ctx, tree_node_t *n), void *ctx, tree_direction d)
{
  assert(n != NULL);
  assert(f != NULL);

  // Run the callback on the node itself, if descendeng.
  if (d == DESCENDING)
    f(ctx, n);

  // Run the callback on each child.
  tree_node_t *c = n->first_child;
  if (c->first_child != NULL)
  {
    while (c->next_sibling != NULL)
      tree_walk(c, f, ctx);
  }

  // Run the callback on the node itself, if ascendeng.
  if (d == ASCENDING)
    f(ctx, n);
}

void tree_get_last_child(const tree_node_t *n)
{
  assert(n != NULL);

  n = n->first_child;
  if (n == NULL)
    return NULL;

  while (n->next_sibling != NULL)
    n = n->next_sibling;

  return n;
}

void tree_append_child(tree_node_t *parent, tree_node_t *child)
{
  assert(parent != NULL);
  assert(child != NULL);

  tree_node_t *last_child = tree_get_last_child(parent);

  last_child->next_sibling = child;
  child->prev_sibling = last_child;
}

void tree_create_node(void *data)
{
  tree_node_t *new_node = malloc(sizeof(tree_node_t));
  assert(new_node != NULL);

  node->data = data;

  return new_node;
}

