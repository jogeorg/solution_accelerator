export const resources = [];

export let selectedTeam = null;

export const getSelectedTeam = () => {
    return selectedTeam;
};

export const setSelectedTeam = (team) => {
    selectedTeam = team;
};

export class VirtualMachine {
    constructor(name, size, disk_size, image, count, service) {
        this.name = name;
        this.size = size;
        this.disk_size = disk_size;
        this.image = image;
        this.count = count;
        this.service = service;
    }
}