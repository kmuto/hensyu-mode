; -*- coding: euc-jp-unix -*-
;; hensyu-mode.el --- major mode for TopStudio tag
;; Copyright 1999-2015 Kenshi Muto <kmuto@debian.org>

;; Author: Kenshi Muto <kmuto@debian.org>
;; URL: https://github.com/kmuto/hensyu-mode

;; Hensyu text editing mode
;;
;; License:
;;   GNU General Public License version 2 (see COPYING)

;; �Խ��⡼��

;; C-c C-a �桼���������Խ��ؤΥ�å�����
;; C-c C-k �桼������
;; C-c C-d DTP�ؤΥ�å�����
;; C-c C-s �����򸡺�
;; C-c C-r ������򤢤Ȥǳ�ǧ
;; C-c C-h �������ȥ�����
;; C-c 1   ����URI�򸡺����ƥ֥饦���򳫤�
;; C-c 2   �ϰϤ�URI�Ȥ��ƥ֥饦���򳫤�
;; C-c !   �������򼨤�
;; C-c (   ����(
;; C-c )   ����)
;; C-c [   ��
;; C-c ]    ��
;; C-c -    ��

(run-hooks 'hensyu-load-hook)

(defconst hensyu-version "1.14"
  "�Խ��⡼�ɥС������")

;; ��������
(defvar hensyu-load-hook nil
  "�Խ��⡼�ɥեå�")

(defvar hensyu-mode-map (make-sparse-keymap)
  "�Խ��⡼�ɥ����ޥå�")

(defvar hensyu-highlight-face-list
  '(hensyu-underline
    hensyu-bold
    hensyu-italic
    hensyu-comment
    )
  "�Խ��⡼��face")

(defvar hensyu-name-list 
  '(("�Խ���" . "�Խ���")
    ("������" . "������")
    ("����" . "����")
    ("����" . "��")
    ("kmuto" . "��")
    )
  "�Խ��⡼�ɤ�̾���ꥹ��"
)
(defvar hensyu-dtp-list
  '("DTPϢ��")
  "DTPô��̾�ꥹ��"
)

(defvar hensyu-mode-name "�Խ���" "�桼�����θ���")
(defvar hensyu-mode-tip-name "�Խ���" "������̾��")
(defvar hensyu-mode-dtp "DTPϢ��" "DTPô����̾��")
(defvar hensyu-comment-start "����" "�Խ������γ���ʸ��")
(defvar hensyu-comment-end "����" "�Խ������ν�λʸ��")
(defvar hensyu-index-start "//index{" "���������γ���ʸ��")
(defvar hensyu-index-end "//}" "���������ν�λʸ��")
(defvar hensyu-tex-mode nil "nil:�̾�⡼�� t:EWB�����Υ⡼��")
(defvar hensyu-use-skk-mode t "t:SKK�⡼�ɤǳ���")

(defvar hensyu-key-mapping
  '(
   ("[" . "��")
   ("]" . "��")
   ("(" . "��")
   (")" . "��")
   ("8" . "��")
   ("9" . "��")
   ("-" . "��")
   ("*" . "��")
   ("/" . "��")
   ("\\" . "��")
   (" " . "��")
   (":" . "��")
   ("<" . "<\\<>")
   )
  "�����ִ�����")

(defvar hensyu-uri-regexp "\\(\\b\\(s?https?\\|ftp\\|file\\|gopher\\|news\\|telnet\\|wais\\|mailto\\):\\(//[-a-zA-Z0-9_.]+:[0-9]*\\)?[-a-zA-Z0-9_=?#$@~`%&*+|\\/.,]*[-a-zA-Z0-9_=#$@~`%&*+|\\/]+\\)\\|\\(\\([^-A-Za-z0-9!_.%]\\|^\\)[-A-Za-z0-9._!%]+@[A-Za-z0-9][-A-Za-z0-9._!]+[A-Za-z0-9]\\)" "URI������ʬ����ɽ��")

;; �Խ��⡼�ɥ١����ؿ�
(defun hensyu-mode ()
  "�᥸�㡼�Խ��⡼��"
  (interactive)
  (kill-all-local-variables)

  (let ()

    (setq major-mode 'hensyu-mode
	  mode-name hensyu-mode-name
	  )
    
    (auto-fill-mode 0)
    (if hensyu-use-skk-mode (skk-mode))

    ;; �ե�����
    (require 'font-lock)

    (defcustom hensyu-font-lock-keywords
	`(("����[^��]*����" . hensyu-mode-comment-face)
	  ("//hidden{.*?//}" . hensyu-mode-comment-face)
	  ("��[^��]*��" . hensyu-mode-comment-face)
	  ("<��[^>]*>" . hensyu-mode-comment-face)
	  ("<����[^>]*>" . hensyu-mode-comment-face)
	  ("<����[^>]*>" . hensyu-mode-comment-face)
	  ("<����[^>]*>" . hensyu-mode-comment-face)
	  ("<��������[^>]*>" . hensyu-mode-comment-face)
	  ("^��.*" . hensyu-mode-title-face)
	  ("^//i+��.*" . hensyu-mode-title-face)
	  ("<U>.*?<P>" . hensyu-mode-underline-face)
	  ("��.*?��" . hensyu-mode-underline-face)
	  ("<B>.*?<P>" . hensyu-mode-bold-face)
	  ("��.*?��" . hensyu-mode-bold-face)
	  ("<I>.*?<P>" . hensyu-mode-italic-face)
	  ("��.*?��" . hensyu-mode-italic-face)
	  ("//it{.*?//}" . hensyu-mode-italic-face)
	  ("//g1{.*?//}" . hensyu-mode-bold-face)
	  ("//index{.*?//}" . hensyu-mode-hide-face)
	  ("<\<>" . hensyu-mode-bracket-face)
	  )
	"�Խ��⡼�ɤ�face"
	:group 'hensyu-mode
	:type 'list)

    (defface hensyu-mode-comment-face
      '((t (:foreground "Red")))
      "�����ȤΥե�����"
      :group 'hensyu-mode)
    (defface hensyu-mode-title-face
      '((t (:foreground "darkgreen")))
      "�����ȥ�Υե�����"
      :group 'hensyu-mode)
    (defface hensyu-mode-underline-face
      '((t (:underline t :foreground "DarkBlue")))
      "��������饤��Υե�����"
      :group 'hensyu-mode)
    (defface hensyu-mode-bold-face
      '((t (:bold t :foreground "Blue")))
      "�ܡ���ɤΥե�����"
      :group 'hensyu-mode)
    (defface hensyu-mode-italic-face
      '((t (:italic t :bold t :foreground "DarkRed")))
      "������å��Υե�����"
      :group 'hensyu-mode)
    (defface hensyu-mode-bracket-face
      '((t (:bold t :foreground "DarkBlue")))
      "<�Υե�����"
      :group 'hensyu-mode)
    (defface hensyu-mode-hide-face
      '((t (:bold t :foreground "plum4")))
      "index�Υե�����"
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

;; �꡼����������
(defun hensyu-block-region (pattern &optional force start end)
  "�����ΰ��Ϥॿ��������"
  (interactive "s������: \nP\nr")

  (save-restriction
    (narrow-to-region start end)
     (goto-char (point-min))
     (insert hensyu-comment-start "����:" pattern " -" hensyu-mode-name hensyu-comment-end "\n")
     (goto-char (point-max))
     (insert hensyu-comment-start "��λ:" pattern " -" hensyu-mode-name hensyu-comment-end "\n")
     )
  )

;; �ե�����դ�
(defun hensyu-string-region (markb marke start end)
  "�����ΰ�˥ե���Ȥ�����"

  (save-restriction
    (narrow-to-region start end)
    (goto-char (point-min))
    (insert markb)
    (goto-char (point-max))
    (insert marke)
    )
  )

(defun hensyu-bold-region (start end)
  "�ܡ���ɥե���ȥ���"
  (interactive "r")
  (if (progn (not hensyu-tex-mode))
;;      (hensyu-string-region "<B>" "<P>" start end)
      (hensyu-string-region "��" "��" start end)
      (hensyu-string-region "//b{" "//}" start end)
      )
  )
(defun hensyu-italic-region (start end)
  "������å��ե���ȥ���"
  (interactive "r")
  (if (progn (not hensyu-tex-mode))
;;      (hensyu-string-region "<I>" "<P>" start end)
      (hensyu-string-region "��" "��" start end)
      (hensyu-string-region "//it{" "//}" start end)
      )
  )
(defun hensyu-underline-region (start end)
  "��������饤��(�ºݤϥ����ץե����)�ե���ȥ���"
  (interactive "r")
  (if (progn (not hensyu-tex-mode))
;;      (hensyu-string-region "<U>" "<P>" start end)
      (hensyu-string-region "��" "��" start end)
      (hensyu-string-region "//tt{" "//}" start end)
      )
  )

;; �Խ������λ
(defun hensyu-kokomade ()
  (interactive)
  "�����λ����������"
  (insert hensyu-comment-start "�����ޤ� -" hensyu-mode-name hensyu-comment-end "\n")
  )

;; �Խ�������
(defun hensyu-normal-comment (pattern &optional force)
  (interactive "s������: \nP")
  "�����Ȥ�����"
  (if (progn (not hensyu-tex-mode))
      (insert hensyu-comment-start pattern " -" hensyu-mode-name hensyu-comment-end)
      (insert "//hidden{" pattern " -" hensyu-mode-name "//}")
      )
  )

;; DTP����������
(defun hensyu-dtp-comment (pattern &optional force)
  (interactive "sDTP����������: \nP")
  "DTP���������Ȥ�����"
  (insert hensyu-comment-start hensyu-mode-dtp ":" pattern " -" hensyu-mode-name hensyu-comment-end)
  )

;; ���
(defun hensyu-tip-comment (pattern &optional force)
  (interactive "s��ᥳ����: \nP")
  "��ᥳ���Ȥ�����"
  (insert hensyu-comment-start hensyu-mode-tip-name ":" pattern " -" hensyu-mode-name hensyu-comment-end)
  )

;; ����
(defun hensyu-reference-comment ()
  (interactive)
  "���ȥ����Ȥ�����"
  (insert hensyu-comment-start "�������ǧ -" hensyu-mode-name hensyu-comment-end)
  )

;; ����
(defun hensyu-index-comment (pattern &optional force)
  (interactive "s����: \nP")
  "������ɤ�����"
  (insert hensyu-index-start pattern hensyu-index-end)
  )

;; �إå�
(defun hensyu-header (pattern &optional force)
  (interactive "s�إå���٥�: \nP")
  "��ᥳ���Ȥ�����"
  (if (progn (not hensyu-tex-mode))
      (insert "��H" pattern "��")
      (insert "//" pattern)
      )
  )

;; �֥饦��
(defun hensyu-search-uri ()
  (interactive)
  "����URI�򸡺����ƥ֥饦����ɽ��"
  (re-search-forward hensyu-uri-regexp)
  (goto-char (match-beginning 1))
  (browser-url (match-string 1))
  )

(defun hensyu-search-uri2 (start end)
  (interactive "r")
  "�����ΰ��֥饦����ɽ��"
  (message (buffer-substring-no-properties start end))
  (browse-url (buffer-substring-no-properties start end))
  )

;; ����ʸ��
(defun hensyu-zenkaku-mapping (key)
  "����ʸ��������"
  (insert (cdr (assoc key hensyu-key-mapping)))
)

(defun hensyu-zenkaku-mapping-lparenthesis () (interactive) "����(" (hensyu-zenkaku-mapping "("))
(defun hensyu-zenkaku-mapping-rparenthesis () (interactive) "����)" (hensyu-zenkaku-mapping ")"))
(defun hensyu-zenkaku-mapping-langle () (interactive) "����[" (hensyu-zenkaku-mapping "["))
(defun hensyu-zenkaku-mapping-rangle () (interactive) "����[" (hensyu-zenkaku-mapping "]"))
(defun hensyu-zenkaku-mapping-minus () (interactive) "����-" (hensyu-zenkaku-mapping "-"))
(defun hensyu-zenkaku-mapping-asterisk () (interactive) "����*" (hensyu-zenkaku-mapping "*"))
(defun hensyu-zenkaku-mapping-slash () (interactive) "����/" (hensyu-zenkaku-mapping "/"))
(defun hensyu-zenkaku-mapping-yen () (interactive) "���ѡ�" (hensyu-zenkaku-mapping "\\"))
(defun hensyu-zenkaku-mapping-space () (interactive) "���� " (hensyu-zenkaku-mapping " "))
(defun hensyu-zenkaku-mapping-colon () (interactive) "����:" (hensyu-zenkaku-mapping ":"))
(defun hensyu-zenkaku-mapping-lbracket () (interactive) "<����" (hensyu-zenkaku-mapping "<"))

;; ���ܥ⡼�ɤ��ѹ�
(defun hensyu-change-mode ()
  (interactive)
  "�Խ��⡼�ɤ��ѹ�"
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
    (message (concat "�Խ��⡼��: " _message ":"))
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
  (message (concat "���ߤΥ⡼��: " hensyu-mode-name))
  (setq mode-name hensyu-mode-name)
  )

(defun hensyu-change-mode-sub (number)
  "�Խ��⡼���ѹ����֥롼����"
  (let (list)
    (setq list (nth number hensyu-name-list))
    (setq hensyu-mode-name (car list))
    )
  )

;; DTP ���ѹ�
(defun hensyu-change-dtp ()
  (interactive)
  "DTPô�����ѹ�"
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
    (message (concat "DTPô��: " _message ":"))
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
  "DTPô���ѹ����֥롼����"
  (let (list)
    (setq list (nth number hensyu-dtp-list))
    (setq hensyu-dtp-name list)
    (message (concat "���ߤ�DTP: " hensyu-dtp-name))
    )
  )

;; �Ȥ��ѹ�
(defun hensyu-change-mode-sub (number)
  "�Խ��⡼�ɤΥ��֥롼����"
  (let (list)
     (setq list (nth number hensyu-name-list))
     (setq hensyu-mode-name (car list))
     (setq hensyu-tip-name (cdr list))
    )
  )

(defun hensyu-change-tex-mode (key)
  (interactive "c�ȥ⡼�ɻ���: 1.ɸ�� 2.TeX: ")
  "�ȥ⡼�ɤ��ѹ�"
  (progn
    (cond
     ((= key ?1) (progn
		   (setq hensyu-tex-mode nil)
		   (message "�ȥ⡼��: ɸ��⡼�� ������")
		   ))
     ((= key ?2) (progn
		   (setq hensyu-tex-mode t)
		   (message "�ȥ⡼��: TeX�⡼�� ������")
		   ))
     )
    )
  )

(defun hensyu-index-change (start end)
  "�����ΰ������Ȥ���()�ȥ��ڡ�������"
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
  "�����ΰ�Υڡ�����������"
  (interactive "n������: \nP\nr")
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
