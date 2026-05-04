(function () {
  "use strict";

  var STORAGE_KEY = "todo-app-items";
  var state = {
    items: [],
    filter: "all",
  };

  var form = document.getElementById("todo-form");
  var input = document.getElementById("todo-input");
  var listEl = document.getElementById("todo-list");
  var countEl = document.getElementById("todo-count");
  var clearBtn = document.getElementById("clear-completed");
  var filterButtons = document.querySelectorAll(".filters__btn");

  function load() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return;
      var parsed = JSON.parse(raw);
      if (!Array.isArray(parsed)) return;
      state.items = parsed.filter(function (row) {
        return row && typeof row.id === "string" && typeof row.text === "string" && typeof row.done === "boolean";
      });
    } catch (e) {
      state.items = [];
    }
  }

  function save() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state.items));
    } catch (e) {
      /* ignore quota / private mode */
    }
  }

  function uid() {
    return "t-" + Date.now().toString(36) + "-" + Math.random().toString(36).slice(2, 9);
  }

  function visibleItems() {
    if (state.filter === "active") {
      return state.items.filter(function (i) {
        return !i.done;
      });
    }
    if (state.filter === "completed") {
      return state.items.filter(function (i) {
        return i.done;
      });
    }
    return state.items.slice();
  }

  function updateFilterButtons() {
    filterButtons.forEach(function (btn) {
      var f = btn.getAttribute("data-filter");
      var active = f === state.filter;
      btn.classList.toggle("filters__btn--active", active);
      btn.setAttribute("aria-selected", active ? "true" : "false");
    });
  }

  function updateFooter() {
    var activeCount = state.items.filter(function (i) {
      return !i.done;
    }).length;
    var completedCount = state.items.length - activeCount;
    countEl.textContent =
      state.items.length === 0
        ? "暂无任务"
        : "未完成 " + activeCount + " 项" + (state.items.length > 0 ? " · 共 " + state.items.length + " 项" : "");
    clearBtn.hidden = completedCount === 0;
  }

  function render() {
    var items = visibleItems();
    listEl.innerHTML = "";

    if (state.items.length === 0) {
      var empty = document.createElement("li");
      empty.className = "todo-list--empty";
      empty.setAttribute("role", "status");
      empty.textContent = "还没有任务，在上方输入并添加。";
      listEl.appendChild(empty);
      updateFooter();
      updateFilterButtons();
      return;
    }

    if (items.length === 0) {
      var hint = document.createElement("li");
      hint.className = "todo-list--empty";
      hint.setAttribute("role", "status");
      hint.textContent =
        state.filter === "active" ? "没有未完成任务。" : state.filter === "completed" ? "没有已完成任务。" : "没有任务。";
      listEl.appendChild(hint);
      updateFooter();
      updateFilterButtons();
      return;
    }

    items.forEach(function (item) {
      var li = document.createElement("li");
      li.className = "todo-item" + (item.done ? " todo-item--done" : "");
      li.dataset.id = item.id;

      var checkbox = document.createElement("input");
      checkbox.type = "checkbox";
      checkbox.className = "todo-item__check";
      checkbox.checked = item.done;
      checkbox.setAttribute("aria-label", "标记完成：" + item.text);

      var label = document.createElement("label");
      label.className = "todo-item__label";
      label.htmlFor = "cb-" + item.id;
      label.textContent = item.text;

      checkbox.id = "cb-" + item.id;

      var del = document.createElement("button");
      del.type = "button";
      del.className = "todo-item__delete";
      del.setAttribute("aria-label", "删除：" + item.text);
      del.textContent = "删除";

      li.appendChild(checkbox);
      li.appendChild(label);
      li.appendChild(del);
      listEl.appendChild(li);
    });

    updateFooter();
    updateFilterButtons();
  }

  function findIndex(id) {
    for (var i = 0; i < state.items.length; i++) {
      if (state.items[i].id === id) return i;
    }
    return -1;
  }

  form.addEventListener("submit", function (e) {
    e.preventDefault();
    var text = input.value.trim();
    if (!text) return;
    state.items.unshift({ id: uid(), text: text, done: false });
    input.value = "";
    save();
    render();
    input.focus();
  });

  listEl.addEventListener("change", function (e) {
    var target = e.target;
    if (target.classList.contains("todo-item__check")) {
      var li = target.closest(".todo-item");
      if (!li) return;
      var id = li.dataset.id;
      var idx = findIndex(id);
      if (idx === -1) return;
      state.items[idx].done = target.checked;
      save();
      render();
    }
  });

  listEl.addEventListener("click", function (e) {
    var target = e.target;
    if (target.classList.contains("todo-item__delete")) {
      var li = target.closest(".todo-item");
      if (!li) return;
      var id = li.dataset.id;
      var idx = findIndex(id);
      if (idx === -1) return;
      state.items.splice(idx, 1);
      save();
      render();
    }
  });

  filterButtons.forEach(function (btn) {
    btn.addEventListener("click", function () {
      var f = btn.getAttribute("data-filter");
      if (f === "all" || f === "active" || f === "completed") {
        state.filter = f;
        render();
      }
    });
  });

  clearBtn.addEventListener("click", function () {
    state.items = state.items.filter(function (i) {
      return !i.done;
    });
    save();
    render();
  });

  load();
  render();
})();
