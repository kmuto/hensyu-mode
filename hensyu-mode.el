; -*- coding: euc-jp-unix -*-
;; hensyu-mode.el --- major mode for TopStudio tag
;; Copyright 1999-2015 Kenshi Muto <kmuto@debian.org>

;; Author: Kenshi Muto <kmuto@debian.org>
;; URL: https://github.com/kmuto/hensyu-mode

;; Hensyu text editing mode
;;
;; License:
;;   GNU General Public License version 2 (see COPYING)

;; 編集モード

;; C-c C-a ユーザーから編集へのメッセージ
;; C-c C-k ユーザー注
;; C-c C-d DTPへのメッセージ
;; C-c C-s ◆→を検索
;; C-c C-r 参照先をあとで確認
;; C-c C-h ■タイトル挿入
;; C-c 1   近所のURIを検索してブラウザを開く
;; C-c 2   範囲をURIとしてブラウザを開く
;; C-c !   作業途中を示す
;; C-c (   全角(
;; C-c )   全角)
;; C-c [   【
;; C-c ]    】
;; C-c -    −

(run-hooks 'hensyu-load-hook)

(defconst hensyu-version "1.14"
  "編集モードバージョン")

;; 基本設定
(defvar hensyu-load-hook nil
  "編集モードフック")

(defvar hensyu-mode-map (make-sparse-keymap)
  "編集モードキーマップ")

(defvar hensyu-highlight-face-list
  '(hensyu-underline
    hensyu-bold
    hensyu-italic
    hensyu-comment
    )
  "編集モードface")

(defvar hensyu-name-list 
  '(("編集者" . "編集注")
    ("翻訳者" . "翻訳注")
    ("監訳" . "監注")
    ("著者" . "注")
    ("kmuto" . "注")
    )
  "編集モードの名前リスト"
)
(defvar hensyu-dtp-list
  '("DTP連絡")
  "DTP担当名リスト"
)

(defvar hensyu-mode-name "編集者" "ユーザーの権限")
(defvar hensyu-mode-tip-name "編集注" "注釈時の名前")
(defvar hensyu-mode-dtp "DTP連絡" "DTP担当の名前")
(defvar hensyu-comment-start "◆→" "編集タグの開始文字")
(defvar hensyu-comment-end "←◆" "編集タグの終了文字")
(defvar hensyu-index-start "//index{" "索引タグの開始文字")
(defvar hensyu-index-end "//}" "索引タグの終了文字")
(defvar hensyu-tex-mode nil "nil:通常モード t:EWB向けのモード")
(defvar hensyu-use-skk-mode t "t:SKKモードで開始")

(defvar hensyu-key-mapping
  '(
   ("[" . "【")
   ("]" . "】")
   ("(" . "（")
   (")" . "）")
   ("8" . "（")
   ("9" . "）")
   ("-" . "−")
   ("*" . "＊")
   ("/" . "／")
   ("\\" . "￥")
   (" " . "　")
   (":" . "：")
   ("<" . "<\\<>")
   )
  "全角置換キー")

(defvar hensyu-uri-regexp "\\(\\b\\(s?https?\\|ftp\\|file\\|gopher\\|news\\|telnet\\|wais\\|mailto\\):\\(//[-a-zA-Z0-9_.]+:[0-9]*\\)?[-a-zA-Z0-9_=?#$@~`%&*+|\\/.,]*[-a-zA-Z0-9_=#$@~`%&*+|\\/]+\\)\\|\\(\\([^-A-Za-z0-9!_.%]\\|^\\)[-A-Za-z0-9._!%]+@[A-Za-z0-9][-A-Za-z0-9._!]+[A-Za-z0-9]\\)" "URI選択部分正規表現")

;; 編集モードベース関数
(defun hensyu-mode ()
  "メジャー編集モード"
  (interactive)
  (kill-all-local-variables)

  (let ()

    (setq major-mode 'hensyu-mode
	  mode-name hensyu-mode-name
	  )
    
    (auto-fill-mode 0)
    (if hensyu-use-skk-mode (skk-mode))

    ;; フェイス
    (require 'font-lock)

    (defcustom hensyu-font-lock-keywords
	`(("◆→[^◆]*←◆" . hensyu-mode-comment-face)
	  ("//hidden{.*?//}" . hensyu-mode-comment-face)
	  ("【[^】]*】" . hensyu-mode-comment-face)
	  ("<注[^>]*>" . hensyu-mode-comment-face)
	  ("<編注[^>]*>" . hensyu-mode-comment-face)
	  ("<訳注[^>]*>" . hensyu-mode-comment-face)
	  ("<監注[^>]*>" . hensyu-mode-comment-face)
	  ("<監訳者注[^>]*>" . hensyu-mode-comment-face)
	  ("^■.*" . hensyu-mode-title-face)
	  ("^//i+　.*" . hensyu-mode-title-face)
	  ("<U>.*?<P>" . hensyu-mode-underline-face)
	  ("△.*?☆" . hensyu-mode-underline-face)
	  ("<B>.*?<P>" . hensyu-mode-bold-face)
	  ("★.*?☆" . hensyu-mode-bold-face)
	  ("<I>.*?<P>" . hensyu-mode-italic-face)
	  ("▲.*?☆" . hensyu-mode-italic-face)
	  ("//it{.*?//}" . hensyu-mode-italic-face)
	  ("//g1{.*?//}" . hensyu-mode-bold-face)
	  ("//index{.*?//}" . hensyu-mode-hide-face)
	  ("<\<>" . hensyu-mode-bracket-face)
	  )
	"編集モードのface"
	:group 'hensyu-mode
	:type 'list)

    (defface hensyu-mode-comment-face
      '((t (:foreground "Red")))
      "コメントのフェイス"
      :group 'hensyu-mode)
    (defface hensyu-mode-title-face
      '((t (:foreground "darkgreen")))
      "タイトルのフェイス"
      :group 'hensyu-mode)
    (defface hensyu-mode-underline-face
      '((t (:underline t :foreground "DarkBlue")))
      "アンダーラインのフェイス"
      :group 'hensyu-mode)
    (defface hensyu-mode-bold-face
      '((t (:bold t :foreground "Blue")))
      "ボールドのフェイス"
      :group 'hensyu-mode)
    (defface hensyu-mode-italic-face
      '((t (:italic t :bold t :foreground "DarkRed")))
      "イタリックのフェイス"
      :group 'hensyu-mode)
    (defface hensyu-mode-bracket-face
      '((t (:bold t :foreground "DarkBlue")))
      "<のフェイス"
      :group 'hensyu-mode)
    (defface hensyu-mode-hide-face
      '((t (:bold t :foreground "plum4")))
      "indexのフェイス"
      :group 'hensyu-mode)

    (defvar hensyu-mode-comment-face 'hensyu-mode-comment-face)
    (defvar hensyu-mode-title-face 'hensyu-mode-title-face)
    (defvar hensyu-mode-underline-face 'hensyu-mode-underline-face)
    (defvar hensyu-mode-bold-face 'hensyu-mode-bold-face)
    (defvar hensyu-mode-italic-face 'hensyu-mode-italic-face)
    (defvar hensyu-mode-bracket-face 'hensyu-mode-bracket-face)
    (defvar hensyu-mode-hide-face 'hensyu-mode-hide-face)

    (make-local-variable 'font-lock-defaults)
    (setq font-lock-defaults '(hensyu-font-lock-keywords t))
    (turn-on-font-lock)

    (define-key hensyu-mode-map "\C-c\C-e" 'hensyu-block-region)
    (define-key hensyu-mode-map "\C-c\C-fb" 'hensyu-bold-region)
    (define-key hensyu-mode-map "\C-c\C-fi" 'hensyu-italic-region)
    (define-key hensyu-mode-map "\C-c\C-fe" 'hensyu-italic-region)
    (define-key hensyu-mode-map "\C-c\C-ft" 'hensyu-underline-region)
    (define-key hensyu-mode-map "\C-c\C-fu" 'hensyu-underline-region)
    (define-key hensyu-mode-map "\C-c\C-f\C-b" 'hensyu-bold-region)
    (define-key hensyu-mode-map "\C-c\C-f\C-i" 'hensyu-italic-region)
    (define-key hensyu-mode-map "\C-c\C-f\C-e" 'hensyu-italic-region)
    (define-key hensyu-mode-map "\C-c\C-f\C-t" 'hensyu-underline-region)
    (define-key hensyu-mode-map "\C-c\C-f\C-u" 'hensyu-underline-region)
    (define-key hensyu-mode-map "\C-c!" 'hensyu-kokomade)
    (define-key hensyu-mode-map "\C-c\C-a" 'hensyu-normal-comment)
    (define-key hensyu-mode-map "\C-c\C-d" 'hensyu-dtp-comment)
    (define-key hensyu-mode-map "\C-c\C-k" 'hensyu-tip-comment)
    (define-key hensyu-mode-map "\C-c\C-r" 'hensyu-reference-comment)
    (define-key hensyu-mode-map "\C-c\C-i" 'hensyu-index-comment)
    (define-key hensyu-mode-map "\C-c\C-p" 'hensyu-header)

    (define-key hensyu-mode-map "\C-c1" 'hensyu-search-uri)
    (define-key hensyu-mode-map "\C-c2" 'hensyu-search-uri2)

    (define-key hensyu-mode-map "\C-c8" 'hensyu-zenkaku-mapping-lparenthesis)
    (define-key hensyu-mode-map "\C-c\(" 'hensyu-zenkaku-mapping-lparenthesis)
    (define-key hensyu-mode-map "\C-c9" 'hensyu-zenkaku-mapping-rparenthesis)
    (define-key hensyu-mode-map "\C-c\)" 'hensyu-zenkaku-mapping-rparenthesis)
    (define-key hensyu-mode-map "\C-c\[" 'hensyu-zenkaku-mapping-langle)
    (define-key hensyu-mode-map "\C-c\]" 'hensyu-zenkaku-mapping-rangle)
    (define-key hensyu-mode-map "\C-c-" 'hensyu-zenkaku-mapping-minus)
    (define-key hensyu-mode-map "\C-c*" 'hensyu-zenkaku-mapping-asterisk)
    (define-key hensyu-mode-map "\C-c/" 'hensyu-zenkaku-mapping-slash)
    (define-key hensyu-mode-map "\C-c\\" 'hensyu-zenkaku-mapping-yen)
    (define-key hensyu-mode-map "\C-c " 'hensyu-zenkaku-mapping-space)
    (define-key hensyu-mode-map "\C-c:" 'hensyu-zenkaku-mapping-colon)
    (define-key hensyu-mode-map "\C-c<" 'hensyu-zenkaku-mapping-lbracket)

    (define-key hensyu-mode-map "\C-c\C-t1" 'hensyu-change-mode)
    (define-key hensyu-mode-map "\C-c\C-t2" 'hensyu-change-dtp)
    (define-key hensyu-mode-map "\C-c\C-t3" 'hensyu-change-tex-mode)

    (define-key hensyu-mode-map "\C-c\C-y" 'hensyu-index-change)

    (use-local-map hensyu-mode-map)

    (run-hooks 'hensyu-mode-hook)
    )
  )

;; リージョン取り込み
(defun hensyu-block-region (pattern &optional force start end)
  "選択領域を囲むタグを設定"
  (interactive "sコメント: \nP\nr")

  (save-restriction
    (narrow-to-region start end)
     (goto-char (point-min))
     (insert hensyu-comment-start "開始:" pattern " -" hensyu-mode-name hensyu-comment-end "\n")
     (goto-char (point-max))
     (insert hensyu-comment-start "終了:" pattern " -" hensyu-mode-name hensyu-comment-end "\n")
     )
  )

;; フォント付け
(defun hensyu-string-region (markb marke start end)
  "選択領域にフォントを設定"

  (save-restriction
    (narrow-to-region start end)
    (goto-char (point-min))
    (insert markb)
    (goto-char (point-max))
    (insert marke)
    )
  )

(defun hensyu-bold-region (start end)
  "ボールドフォントタグ"
  (interactive "r")
  (if (progn (not hensyu-tex-mode))
;;      (hensyu-string-region "<B>" "<P>" start end)
      (hensyu-string-region "★" "☆" start end)
      (hensyu-string-region "//b{" "//}" start end)
      )
  )
(defun hensyu-italic-region (start end)
  "イタリックフォントタグ"
  (interactive "r")
  (if (progn (not hensyu-tex-mode))
;;      (hensyu-string-region "<I>" "<P>" start end)
      (hensyu-string-region "▲" "☆" start end)
      (hensyu-string-region "//it{" "//}" start end)
      )
  )
(defun hensyu-underline-region (start end)
  "アンダーライン(実際はタイプフォント)フォントタグ"
  (interactive "r")
  (if (progn (not hensyu-tex-mode))
;;      (hensyu-string-region "<U>" "<P>" start end)
      (hensyu-string-region "△" "☆" start end)
      (hensyu-string-region "//tt{" "//}" start end)
      )
  )

;; 編集一時終了
(defun hensyu-kokomade ()
  (interactive)
  "一時終了タグを挿入"
  (insert hensyu-comment-start "ここまで -" hensyu-mode-name hensyu-comment-end "\n")
  )

;; 編集コメント
(defun hensyu-normal-comment (pattern &optional force)
  (interactive "sコメント: \nP")
  "コメントを挿入"
  (if (progn (not hensyu-tex-mode))
      (insert hensyu-comment-start pattern " -" hensyu-mode-name hensyu-comment-end)
      (insert "//hidden{" pattern " -" hensyu-mode-name "//}")
      )
  )

;; DTP向けコメント
(defun hensyu-dtp-comment (pattern &optional force)
  (interactive "sDTP向けコメント: \nP")
  "DTP向けコメントを挿入"
  (insert hensyu-comment-start hensyu-mode-dtp ":" pattern " -" hensyu-mode-name hensyu-comment-end)
  )

;; 注釈
(defun hensyu-tip-comment (pattern &optional force)
  (interactive "s注釈コメント: \nP")
  "注釈コメントを挿入"
  (insert hensyu-comment-start hensyu-mode-tip-name ":" pattern " -" hensyu-mode-name hensyu-comment-end)
  )

;; 参照
(defun hensyu-reference-comment ()
  (interactive)
  "参照コメントを挿入"
  (insert hensyu-comment-start "参照先確認 -" hensyu-mode-name hensyu-comment-end)
  )

;; 索引
(defun hensyu-index-comment (pattern &optional force)
  (interactive "s索引: \nP")
  "索引ワードを挿入"
  (insert hensyu-index-start pattern hensyu-index-end)
  )

;; ヘッダ
(defun hensyu-header (pattern &optional force)
  (interactive "sヘッダレベル: \nP")
  "注釈コメントを挿入"
  (if (progn (not hensyu-tex-mode))
      (insert "■H" pattern "■")
      (insert "//" pattern)
      )
  )

;; ブラウズ
(defun hensyu-search-uri ()
  (interactive)
  "手近なURIを検索してブラウザで表示"
  (re-search-forward hensyu-uri-regexp)
  (goto-char (match-beginning 1))
  (browser-url (match-string 1))
  )

(defun hensyu-search-uri2 (start end)
  (interactive "r")
  "選択領域をブラウザで表示"
  (message (buffer-substring-no-properties start end))
  (browse-url (buffer-substring-no-properties start end))
  )

;; 全角文字
(defun hensyu-zenkaku-mapping (key)
  "全角文字の挿入"
  (insert (cdr (assoc key hensyu-key-mapping)))
)

(defun hensyu-zenkaku-mapping-lparenthesis () (interactive) "全角(" (hensyu-zenkaku-mapping "("))
(defun hensyu-zenkaku-mapping-rparenthesis () (interactive) "全角)" (hensyu-zenkaku-mapping ")"))
(defun hensyu-zenkaku-mapping-langle () (interactive) "全角[" (hensyu-zenkaku-mapping "["))
(defun hensyu-zenkaku-mapping-rangle () (interactive) "全角[" (hensyu-zenkaku-mapping "]"))
(defun hensyu-zenkaku-mapping-minus () (interactive) "全角-" (hensyu-zenkaku-mapping "-"))
(defun hensyu-zenkaku-mapping-asterisk () (interactive) "全角*" (hensyu-zenkaku-mapping "*"))
(defun hensyu-zenkaku-mapping-slash () (interactive) "全角/" (hensyu-zenkaku-mapping "/"))
(defun hensyu-zenkaku-mapping-yen () (interactive) "全角￥" (hensyu-zenkaku-mapping "\\"))
(defun hensyu-zenkaku-mapping-space () (interactive) "全角 " (hensyu-zenkaku-mapping " "))
(defun hensyu-zenkaku-mapping-colon () (interactive) "全角:" (hensyu-zenkaku-mapping ":"))
(defun hensyu-zenkaku-mapping-lbracket () (interactive) "<タグ" (hensyu-zenkaku-mapping "<"))

;; 基本モードの変更
(defun hensyu-change-mode ()
  (interactive)
  "編集モードの変更"
  (let (key _message _element (_list hensyu-name-list) (sum 0))
    (while _list
      (setq _element (car (car _list)))
      (setq sum ( + sum 1))
      (if _message
	(setq _message (format "%s%d.%s " _message sum _element))
	(setq _message (format "%d.%s " sum _element))
	)
      (setq _list (cdr _list))
      )
    (message (concat "編集モード: " _message ":"))
    (setq key (read-char))
    (cond
     ((eq key ?1) (hensyu-change-mode-sub 0))
     ((eq key ?2) (hensyu-change-mode-sub 1))
     ((eq key ?3) (hensyu-change-mode-sub 2))
     ((eq key ?4) (hensyu-change-mode-sub 3))
     ((eq key ?5) (hensyu-change-mode-sub 4))
     )
    )
  (setq hensyu-mode-tip-name (cdr (assoc hensyu-mode-name hensyu-name-list)))
  (message (concat "現在のモード: " hensyu-mode-name))
  (setq mode-name hensyu-mode-name)
  )

(defun hensyu-change-mode-sub (number)
  "編集モード変更サブルーチン"
  (let (list)
    (setq list (nth number hensyu-name-list))
    (setq hensyu-mode-name (car list))
    )
  )

;; DTP の変更
(defun hensyu-change-dtp ()
  (interactive)
  "DTP担当の変更"
  (let (key _message _element (_list hensyu-dtp-list) (sum 0))
    (while _list
      (setq _element (car _list))
      (setq sum ( + sum 1))
      (if _message
	(setq _message (format "%s%d.%s " _message sum _element))
	(setq _message (format "%d.%s " sum _element))
	)
      (setq _list (cdr _list))
      )
    (message (concat "DTP担当: " _message ":"))
    (setq key (read-char))
    (cond
     ((eq key ?1) (hensyu-change-dtp-mode-sub 0))
     ((eq key ?2) (hensyu-change-dtp-mode-sub 1))
     ((eq key ?3) (hensyu-change-dtp-mode-sub 2))
     ((eq key ?4) (hensyu-change-dtp-mode-sub 3))
     ((eq key ?5) (hensyu-change-dtp-mode-sub 4))
     )
    )
  )

(defun hensyu-change-dtp-mode-sub (number)
  "DTP担当変更サブルーチン"
  (let (list)
    (setq list (nth number hensyu-dtp-list))
    (setq hensyu-dtp-name list)
    (message (concat "現在のDTP: " hensyu-dtp-name))
    )
  )

;; 組の変更
(defun hensyu-change-mode-sub (number)
  "編集モードのサブルーチン"
  (let (list)
     (setq list (nth number hensyu-name-list))
     (setq hensyu-mode-name (car list))
     (setq hensyu-tip-name (cdr list))
    )
  )

(defun hensyu-change-tex-mode (key)
  (interactive "c組モード指定: 1.標準 2.TeX: ")
  "組モードの変更"
  (progn
    (cond
     ((= key ?1) (progn
		   (setq hensyu-tex-mode nil)
		   (message "組モード: 標準モード に設定")
		   ))
     ((= key ?2) (progn
		   (setq hensyu-tex-mode t)
		   (message "組モード: TeXモード に設定")
		   ))
     )
    )
  )

(defun hensyu-index-change (start end)
  "選択領域を索引として()とスペースを取る"
  (interactive "r")
  (let (_hensyu-index-buffer)
    
    (save-restriction
      (narrow-to-region start end)
      (setq _hensyu-index-buffer (buffer-substring-no-properties start end))
      (goto-char (point-min))
      (while (re-search-forward "\(\\|\)\\| " nil t)
	(replace-match "" nil nil))
      (goto-char (point-max))
      (insert "@" _hensyu-index-buffer)
      )
    )
  )

(defun page-increment-region (pattern &optional force start end)
  "選択領域のページ数を増減"
  (interactive "n増減値: \nP\nr")
  (save-restriction
    (narrow-to-region start end)
    (let ((pos (point-min)))
      (goto-char pos)
      (while (setq pos (re-search-forward "^\\([0-9][0-9]*\\)\t" nil t))
        (replace-match (concat (number-to-string (+ pattern (string-to-number (match-string 1)))) "\t"))
      )
    )
  )
)

(provide 'hensyu-mode)

;;; hensyu-mode.el ends here
