import React from 'react';

import Group, { category, coalition, attributes } from '../model/group';
import { Layer, Feature } from "react-mapbox-gl";

import BlueAir from '../assets/Blue-Air.png';
import BlueGround from '../assets/Blue-Ground.png';
import RedAir from '../assets/Red-Air.png'
import RedGround from '../assets/Red-Ground.png';
import RedSAM from '../assets/Red-SAM.png';

const RedGroundImage = new Image(35, 35)
RedGroundImage.src = RedGround;
const RedAirImage = new Image(35, 35)
RedAirImage.src = RedAir;
const RedSAMImage = new Image(35, 35)
RedSAMImage.src = RedSAM
const BlueGroundImage = new Image(35, 35)
BlueGroundImage.src = BlueGround;
const BlueAirImage = new Image(35, 35)
BlueAirImage.src = BlueAir;


function renderGroup(group: Group, clickHandler: (group: Group) => void) {
    const key = `${group.type}${group.latitude}${group.longitude}`;
    return (
        <Feature 
            coordinates={[group.longitude, group.latitude]} 
            properties={group} 
            key={key}
            onClick={(mapWithEvent) => {
                    clickHandler(group);
                }
            }
        />
    );
}

export default function renderLayers(groups: Group[], clickHandler: (group: Group) => void) {
    const redGroundGroups = groups.filter((group) => 
        group.category === category.Ground && group.coalition === coalition.Red).map((group) => renderGroup(group, clickHandler));
    const redGroundLayer = (<Layer
        key="redGroundLayer"
        type="symbol"
        id="redGroundLayer"
        images={["Red-Ground", RedGroundImage]}
        layout={{ "icon-image": "Red-Ground" }}>
        {redGroundGroups}
    </Layer>)
    const unitsLayers = [redGroundLayer]

    const redAirGroups = groups.filter((group) => group.category === category.Airplane && group.coalition === coalition.Red).map((group) => renderGroup(group, clickHandler));
    const redAirLayer = (<Layer
        key="redAirLayer"
        type="symbol"
        id="redAirLayer"
        images={["Red-Air", RedAirImage]}
        layout={{ "icon-image": "Red-Air" }}>
        {redAirGroups}
    </Layer>)
    unitsLayers.push(redAirLayer)

    // const redSAMGroups = groups.filter((group) => group.category === category.Ground && group.coalition === coalition.Red && group.attributes[attributes.SAM]).map((group) => renderGroup(group, clickHandler));
    // const redSAMLayer = (<Layer
    //     key="redAirLayer"
    //     type="symbol"
    //     id="redAirLayer"
    //     images={["Red-SAM", RedSAMImage]}
    //     layout={{ "icon-image": "Red-SAM" }}>
    //     {redSAMGroups}
    // </Layer>)
    // unitsLayers.push(redSAMLayer)


    const blueGroundGroups = groups.filter((group) => group.category === category.Ground && group.coalition === coalition.Blue).map((group) => renderGroup(group, clickHandler));
    const blueGroundLayer = (<Layer
        key="blueGroundLayer"
        type="symbol"
        id="blueGroundLayer"
        images={["Blue-Ground", BlueGroundImage]}
        layout={{ "icon-image": "Blue-Ground" }}>
        {blueGroundGroups}
    </Layer>)
    unitsLayers.push(blueGroundLayer)

    const blueAirGroups = groups.filter((group) => group.category === category.Airplane && group.coalition === coalition.Blue).map((group) => renderGroup(group, clickHandler));
    const blueAirLayer = (<Layer
        key="blueAirLayer"
        type="symbol"
        id="blueAirLayer"
        images={["Blue-Air", BlueAirImage]}
        layout={{ "icon-image": "Blue-Air" }}>
        {blueAirGroups}
    </Layer>)
    unitsLayers.push(blueAirLayer);

    const blueShipGroups = groups.filter((group) => group.category === category.Ship && group.coalition === coalition.Blue).map((group) => renderGroup(group, clickHandler));
    const blueShipLayer = (<Layer
        key="blueShipLayer"
        type="symbol"
        id="blueShipLayer"
        layout={{ "icon-image": "ro-county-4" }}>
        {blueShipGroups}
    </Layer>)
    unitsLayers.push(blueShipLayer)

    return unitsLayers;
}