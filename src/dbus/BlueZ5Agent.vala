/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright 2014 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* BlueZ5Agent.vala - BlueZ 5 Agent implementation */

using EV3devKit;
using BlueZ5;

namespace BrickManager {
    [DBus (name = "org.bluez.Agent1")]
    public class BlueZ5Agent : Object {
        Screen screen;
        MessageDialog? display_passkey_dialog;

        signal void canceled ();

        public BlueZ5Agent (Screen screen) {
            this.screen = screen;
        }

        public void release () {
            //debug ("Released.");
        }

        public async string request_pin_code (ObjectPath device_path) throws BlueZError
        {
            var result = ConfirmationDialogResult.CANCELED;
            var device = Device.get_for_object_path (device_path);
            var dialog = new Dialog ();
            weak Dialog weak_dialog = dialog;
            var canceled_handler_id = canceled.connect(() => {
                screen.close_window (dialog);
            });
            dialog.closed.connect (() => {
                SignalHandler.disconnect (this, canceled_handler_id);
                request_pin_code.callback ();
            });
            var dialog_vbox = new Box.vertical () {
                spacing = 6
            };
            dialog.add (dialog_vbox);
            var title_label = new Label ("Bluetooth") {
                vertical_align = WidgetAlign.START,
                padding = 3,
                border_bottom = 1
            };
            dialog_vbox.add (title_label);
            var message_label = new Label ("Enter PIN for %s:".printf (device.alias));
            dialog_vbox.add (message_label);
            // TODO: may need to allow alpha and symbol chars.
            var text_entry = new TextEntry ("                ") {
                valid_chars = TextEntry.NUMERIC + " ",
                use_on_screen_keyboard = false,
                horizontal_align = WidgetAlign.CENTER
            };
            dialog_vbox.add (text_entry);
            dialog_vbox.add (new Spacer ());
            var button_vbox = new Box.vertical ();
            dialog_vbox.add (button_vbox);
            var button_hbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER,
                margin_top = -6,
                margin_bottom = 3
            };
            button_vbox.add (button_hbox);
            var reject_button = new Button.with_label ("Reject");
            reject_button.pressed.connect (() => {
                result = ConfirmationDialogResult.REJECTED;
                screen.close_window (weak_dialog);
            });
            button_hbox.add (reject_button);
            var accept_button = new Button.with_label ("Accept");
            accept_button.pressed.connect (() => {
                result = ConfirmationDialogResult.ACCEPTED;
                screen.close_window (weak_dialog);
            });
            button_hbox.add (accept_button);
            text_entry.next_focus_widget_down = accept_button;
            screen.show_window (dialog);
            yield;
            if (result == ConfirmationDialogResult.REJECTED)
                throw new BlueZError.REJECTED ("Rejected.");
            if (result == ConfirmationDialogResult.CANCELED)
                throw new BlueZError.CANCELED ("Canceled.");
            return text_entry.text.replace (" ", "");
        }

        public void display_pin_code (ObjectPath device_path, string pincode) {
            var device = Device.get_for_object_path (device_path);
            var dialog = new MessageDialog ("Bluetooth",
                "PIN code for %s:\n\n%s".printf (device.alias, pincode));
            weak Dialog weak_dialog = dialog;
            var canceled_handler_id = canceled.connect(() => {
                screen.close_window (dialog);
            });
            ulong closed_handler_id = 0;
            closed_handler_id = dialog.closed.connect (() => {
                SignalHandler.disconnect (this, canceled_handler_id);
                SignalHandler.disconnect (weak_dialog, closed_handler_id);
            });
            screen.show_window (dialog);
        }

        public async uint32 request_passkey (ObjectPath device_path) throws BlueZError {
            var result = ConfirmationDialogResult.CANCELED;
            var device = Device.get_for_object_path (device_path);
            var dialog = new Dialog ();
            weak Dialog weak_dialog = dialog;
            var canceled_handler_id = canceled.connect(() => {
                screen.close_window (dialog);
            });
            dialog.closed.connect (() => {
                SignalHandler.disconnect (this, canceled_handler_id);
                request_passkey.callback ();
            });
            var dialog_vbox = new Box.vertical () {
                spacing = 6
            };
            dialog.add (dialog_vbox);
            var title_label = new Label ("Bluetooth") {
                vertical_align = WidgetAlign.START,
                padding = 3,
                border_bottom = 1
            };
            dialog_vbox.add (title_label);
            var message_label = new Label ("Enter passkey for %s:".printf (device.alias));
            dialog_vbox.add (message_label);
            var text_entry = new TextEntry ("000000") {
                valid_chars = TextEntry.NUMERIC,
                use_on_screen_keyboard = false,
                horizontal_align = WidgetAlign.CENTER
            };
            dialog_vbox.add (text_entry);
            dialog_vbox.add (new Spacer ());
            var button_vbox = new Box.vertical ();
            dialog_vbox.add (button_vbox);
            var button_hbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER,
                margin_top = -6,
                margin_bottom = 3
            };
            button_vbox.add (button_hbox);
            var reject_button = new Button.with_label ("Reject");
            reject_button.pressed.connect (() => {
                result = ConfirmationDialogResult.REJECTED;
                screen.close_window (weak_dialog);
            });
            button_hbox.add (reject_button);
            var accept_button = new Button.with_label ("Accept");
            accept_button.pressed.connect (() => {
                result = ConfirmationDialogResult.ACCEPTED;
                screen.close_window (weak_dialog);
            });
            button_hbox.add (accept_button);
            text_entry.next_focus_widget_down = accept_button;
            screen.show_window (dialog);
            yield;
            if (result == ConfirmationDialogResult.REJECTED)
                throw new BlueZError.REJECTED ("Rejected.");
            if (result == ConfirmationDialogResult.CANCELED)
                throw new BlueZError.CANCELED ("Canceled.");
            return (uint32)int.parse (text_entry.text);
        }

        public void display_passkey (ObjectPath device_path, uint32 passkey, uint16 entered) {
            // TODO: Do we want/need to do something with the `entered` parameter?
            var device = Device.get_for_object_path (device_path);
            // This particular function can be called multiple times while the
            // dialog is still displayed, so, if this happens, we remove the old
            // dialog and display a new one.
            if (display_passkey_dialog != null)
                screen.close_window (display_passkey_dialog);
            display_passkey_dialog = new MessageDialog ("Bluetooth",
                "Passkey for %s is: \n\n%s".printf (device.alias, "%06u".printf (passkey)));
            weak Dialog weak_dialog = display_passkey_dialog;
            var canceled_handler_id = canceled.connect(() => {
                screen.close_window (display_passkey_dialog);
            });
            ulong closed_handler_id = 0;
            closed_handler_id = display_passkey_dialog.closed.connect (() => {
                SignalHandler.disconnect (this, canceled_handler_id);
                SignalHandler.disconnect (weak_dialog, closed_handler_id);
                // have to call as function to prevent reference cycle.
                dispose_display_passkey_dialog ();
            });
            screen.show_window (display_passkey_dialog);
        }

        void dispose_display_passkey_dialog () {
            display_passkey_dialog = null;
        }

        public async void request_confirmation (ObjectPath device_path, uint32 passkey)
            throws BlueZError
        {
            var device = Device.get_for_object_path (device_path);
            yield display_confirmation_dialog ("Confirm passkey for %s:\n\n%s".printf (
                device.alias, "%06u".printf (passkey)));
        }

        public async void request_authorization (ObjectPath device_path)
            throws BlueZError
        {
            var device = Device.get_for_object_path (device_path);
            yield display_confirmation_dialog ("Authorize %s.".printf (device.alias));
        }

        public async void authorize_service (ObjectPath device_path, string uuid)
            throws BlueZError
        {
            var device = Device.get_for_object_path (device_path);
            // TODO: translate uuid to service name. May not be needed if we "trust" every device.
            yield display_confirmation_dialog ("Authorize service %s:\n\n%s".printf (
                device.alias, uuid));
        }

        async void display_confirmation_dialog (string message) throws BlueZError {
            var result = ConfirmationDialogResult.CANCELED;
            var dialog = new Dialog ();
            weak Dialog weak_dialog = dialog;
            var canceled_handler_id = canceled.connect(() => {
                screen.close_window (dialog);
            });
            dialog.closed.connect (() => {
                SignalHandler.disconnect (this, canceled_handler_id);
                display_confirmation_dialog.callback ();
            });
            var dialog_vbox = new Box.vertical () {
                spacing = 6
            };
            dialog.add (dialog_vbox);
            var title_label = new Label ("Bluetooth") {
                vertical_align = WidgetAlign.START,
                padding = 3,
                border_bottom = 1
            };
            dialog_vbox.add (title_label);
            var message_label = new Label (message);
            dialog_vbox.add (message_label);
            dialog_vbox.add (new Spacer ());
            var button_vbox = new Box.vertical ();
            dialog_vbox.add (button_vbox);
            var button_hbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER,
                margin = 3
            };
            button_vbox.add (button_hbox);
            var reject_button = new Button.with_label ("Reject");
            reject_button.pressed.connect (() => {
                result = ConfirmationDialogResult.REJECTED;
                screen.close_window (weak_dialog);
            });
            button_hbox.add (reject_button);
            var accept_button = new Button.with_label ("Accept");
            accept_button.pressed.connect (() => {
                result = ConfirmationDialogResult.ACCEPTED;
                screen.close_window (weak_dialog);
            });
            button_hbox.add (accept_button);
            screen.show_window (dialog);
            accept_button.focus ();
            yield;
            if (result == ConfirmationDialogResult.REJECTED)
                throw new BlueZError.REJECTED ("Rejected.");
            if (result == ConfirmationDialogResult.CANCELED)
                throw new BlueZError.CANCELED ("Canceled.");
        }

        public void cancel () {
            canceled ();
        }

        enum ConfirmationDialogResult {
            ACCEPTED,
            REJECTED,
            CANCELED
        }
    }
}